# Game Dev Tutorial 3 - Kontrol Pemain

## Kontrol
- Gerak: `ui_left`, `ui_right`
- Lompat / Lompat Ganda: `ui_up`
- Jongkok (di tanah): `ui_down`
- Dash/Slide: ketuk dua kali `ui_left` atau `ui_right`

## Fitur dan Implementasi

### Gravitasi dan Grounding
- Gravitasi konstan ditambahkan setiap frame fisika ke `velocity.y`.
- Saat menyentuh tanah, penghitung sisa lompatan di-reset supaya lompat ganda tersedia lagi.

### Walking
- Input horizontal mengatur `velocity.x` ke `±walk_speed` dan membalik sprite sesuai arah gerak.
- Saat di tanah dan bergerak memutar animasi `walk`; saat di tanah dan diam memutar `idle`.

### Duck and Crouching
- Menahan `ui_down` saat di tanah menurunkan kecepatan gerak dan memutar animasi `crouch`.
- Input horizontal saat jongkok tetap menggerakkan karakter tetapi dengan kecepatan yang lebih lambat.

### Double Jump
- Menekan `ui_up` di tanah mengatur `velocity.y` ke `jump_speed` dan mengisi ulang sisa lompatan.
- Di udara, jika masih ada jatah lompatan, menekan `ui_up` mengonsumsi satu dan memberi dorongan ke atas yang sama.
- Animasi di udara berpindah ke `jump` saat naik dan `fall` saat turun berdasarkan `velocity.y`.

### Dash / Slide with multiple taps
- Jam ketukan melacak waktu tekan terakhir untuk tiap arah horizontal.
- Jika arah yang sama ditekan dua kali dalam rentang `double_tap_window` dan cooldown dash kosong, dash dimulai ke arah tersebut.
- Selama dash, `velocity.x` dipaksa ke `dash_speed`, `velocity.y` dijepit ke 0, input gerak diabaikan, dan animasi `slide` diputar.

### Dash Cooldown
- Setelah dash dimulai, timer cooldown di-set. Dash baru diblokir sampai timer habis.
- Cooldown mencegah dash beruntun di udara yang bisa membuat pemain melayang.

### Pemilihan Animasi
- Status dash mengatur animasinya sendiri dan mengembalikan proses frame lebih awal.
- Jongkok menimpa walk/idle saat di tanah.
- Saat di udara, animasi dipilih antara `jump` atau `fall` berdasarkan tanda `velocity.y`.
- Walk dan idle dipilih berdasarkan kecepatan horizontal ketika di tanah dan tidak jongkok.