#!/usr/bin/env python3
"""Uji end-to-end backend PRODUKSI asli: buktikan data tidak hilang saat 'install ulang'.
Alur: register -> buat profil -> sync (progres+state) -> LOGIN ULANG (klien baru) ->
tarik data -> verifikasi semua kembali -> uji merge GREATEST -> bersihkan profil."""
import json, os, sys, time, urllib.request, urllib.error

# Bisa ditimpa lewat env: BASE_URL=https://.../backend/api.php python3 backend_smoke_test.py
BASE = os.environ.get("BASE_URL", "https://belajaryuk.mkz.my.id/backend/api.php")
EMAIL = f"selftest.{int(time.time())}@example.com"
PASS = "rahasia123"

ok_count = 0
fail_count = 0

def call(action, token=None, body=None, method="POST"):
    url = f"{BASE}?action={action}"
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(url, data=data, method=method)
    req.add_header("Content-Type", "application/json")
    if token:
        req.add_header("Authorization", f"Bearer {token}")
    try:
        with urllib.request.urlopen(req, timeout=25) as r:
            return r.status, json.loads(r.read().decode())
    except urllib.error.HTTPError as e:
        try:
            return e.code, json.loads(e.read().decode())
        except Exception:
            return e.code, {}

def check(label, cond, detail=""):
    global ok_count, fail_count
    mark = "✅" if cond else "❌"
    if cond: ok_count += 1
    else: fail_count += 1
    print(f"  {mark} {label}" + (f"  — {detail}" if detail else ""))

print(f"== Uji backend PRODUKSI ==  ({EMAIL})\n")

# 1. Register
st, r = call("register", body={"email": EMAIL, "password": PASS, "name": "Ortu Tes"})
tokenA = r.get("token")
check("register akun baru", st == 200 and bool(tokenA), f"HTTP {st}")

# 2. me
st, r = call("me", token=tokenA)
check("me() kembalikan email benar", r.get("email") == EMAIL, r.get("email", ""))

# 3. Buat profil
st, r = call("create_profile", token=tokenA, body={"name": "Adik", "avatar": "🐨"})
pid = r.get("id")
check("buat profil anak", st == 200 and bool(pid), f"id={pid}")

# 4. Sync: kirim progres + state (koin, lencana, avatar) + naik kelas 3
state = {"coins": 137, "badges": ["first_win", "streak3"],
         "ownedAvatars": ["🐨", "🦊"], "avatar": "🦊", "streak": 5}
progress = [{"level_id": "math_g1_l1", "stars": 3, "best_pct": 100},
            {"level_id": "math_g1_l2", "stars": 2, "best_pct": 80}]
st, r = call("sync", token=tokenA,
             body={"profile_id": pid, "progress": progress,
                   "state": state, "unlocked_grade": 3})
check("sync simpan progres+state", st == 200 and r.get("ok"), f"HTTP {st}")

print("\n-- Simulasi INSTALL ULANG: klien baru, login ulang dari nol --")

# 5. Login ulang (token baru, seperti buka app di HP baru)
st, r = call("login", body={"email": EMAIL, "password": PASS})
tokenB = r.get("token")
check("login ulang dapat token baru", st == 200 and bool(tokenB), f"HTTP {st}")

# 6. Daftar profil muncul kembali
st, r = call("profiles", token=tokenB)
profs = r.get("profiles", [])
mine = next((p for p in profs if int(p["id"]) == int(pid)), None)
check("profil lama muncul lagi", mine is not None,
      f"{len(profs)} profil, total_stars={mine.get('total_stars') if mine else '-'}")
check("kelas terbuka tersimpan (3)", mine and int(mine.get("unlocked_grade", 0)) == 3,
      f"unlocked_grade={mine.get('unlocked_grade') if mine else '-'}")

# 7. Tarik data (pull-only, seperti app buka beranda: progress kosong, tanpa state)
st, r = call("sync", token=tokenB, body={"profile_id": pid, "progress": []})
srv_prog = {p["level_id"]: p for p in r.get("progress", [])}
srv_state = r.get("state") or {}
check("progres kembali utuh (2 level)", len(srv_prog) == 2, f"{list(srv_prog.keys())}")
check("bintang level l1 = 3", srv_prog.get("math_g1_l1", {}).get("stars") in (3, "3"),
      srv_prog.get("math_g1_l1"))
check("koin kembali = 137", srv_state.get("coins") == 137, f"coins={srv_state.get('coins')}")
check("lencana kembali", srv_state.get("badges") == ["first_win", "streak3"], srv_state.get("badges"))
check("avatar terpakai kembali = 🦊", srv_state.get("avatar") == "🦊", srv_state.get("avatar"))

print("\n-- Uji merge GREATEST (progres tak boleh MUNDUR) --")

# 8a. Kirim bintang LEBIH RENDAH untuk l1 (2 < 3) → harus tetap 3
st, r = call("sync", token=tokenB,
             body={"profile_id": pid,
                   "progress": [{"level_id": "math_g1_l1", "stars": 1, "best_pct": 20}]})
p1 = next((p for p in r.get("progress", []) if p["level_id"] == "math_g1_l1"), {})
check("kirim bintang lebih rendah → server tetap 3", int(p1.get("stars", 0)) == 3,
      f"stars={p1.get('stars')}")

# 8b. Kirim bintang LEBIH TINGGI untuk l2 (3 > 2) → harus naik ke 3
st, r = call("sync", token=tokenB,
             body={"profile_id": pid,
                   "progress": [{"level_id": "math_g1_l2", "stars": 3, "best_pct": 100}]})
p2 = next((p for p in r.get("progress", []) if p["level_id"] == "math_g1_l2"), {})
check("kirim bintang lebih tinggi → server naik ke 3", int(p2.get("stars", 0)) == 3,
      f"stars={p2.get('stars')}")

print("\n-- Bersihkan (hapus profil tes) --")
st, r = call("delete_profile", token=tokenB, body={"profile_id": pid})
check("hapus profil tes", st == 200 and r.get("ok"), f"HTTP {st}")

print(f"\n== HASIL: {ok_count} lulus, {fail_count} gagal ==")
sys.exit(1 if fail_count else 0)
