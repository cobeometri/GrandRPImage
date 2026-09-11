# Audit icon EventTimer — 11/09/2026

## Phạm vi và trạng thái

Đã rà source tại `D:/DecryptServer/GrandRoleplay/FXSource/resources`, gồm `Config.EventTimer`, các caller `AddEventTimer`, event `codem-hud:client:AddEventTimer` và contract HUD. Đã tìm được **15 resource tiêu thụ, 19 timer gameplay**. EXP x2/x4 dùng chung một timer ID. HUD provider có thêm **4 timer demo** dưới lệnh `/testtimer`; chúng được loại khỏi phạm vi tạo icon gameplay.

Kết quả ban đầu: **6 URL job trỏ tới file thiếu trong kho ảnh local**, **2 timer gameplay chưa sử dụng ảnh** (Parkour và cảnh báo bỏ phương tiện thuê). Những ảnh còn lại trong phạm vi audit đều tồn tại và giải mã hợp lệ. Skyfall đã có ảnh nên không cần tạo lại.

Trạng thái local cuối: **đủ 8 ảnh đã tạo bằng trình tạo ảnh tích hợp và xuất vào `images/`**; 4 file tích hợp Lua đã sửa và kiểm tra. Audit độc lập xác nhận cả 8 file là **PNG 256×256 RGBA**, giải mã hợp lệ, alpha có dải 0–255 và cả bốn góc alpha bằng 0. Tổng dung lượng 8 file là **1.059.310 byte**. Đã kiểm lại 25 file ảnh của 19 timer gameplay, khớp chính xác tên và chữ hoa/thường trong nguồn tham chiếu. Chưa push kho ảnh, chưa restart resource, chưa kiểm tra FiveM live. Sự tồn tại local không đồng nghĩa URL GitHub đã được cập nhật.

## Danh sách đầy đủ

Đường dẫn resource dưới đây tính từ `resources`. Tên ảnh tính từ `D:/DecryptServer/GrandRPImage/images/`. URL cấu hình dùng tiền tố `https://raw.githubusercontent.com/cobeometri/GrandRPImage/refs/heads/main/images/`.

| Resource | Timer gameplay | Nguồn tham chiếu ảnh | Kết quả ban đầu / xử lý |
|---|---|---|---|
| `[minigame]/gta5vn_parkour` | Parkour | `config.lua:22`; `client/client.lua:137` | Ban đầu icon chữ `P`; đổi sang `parkour.png` và truyền `iconUrl` |
| `[minigame]/gta5vn_skyfall` | Skyfall | `config.lua:13`; `client/main.lua:132` | `skyfall.webp` có và hợp lệ; giữ nguyên |
| `[job]/qs-minerjob` | Mỏ Đá x2 | `client/x2.lua:4` | Thiếu `map-ic-mining.png`; tạo đúng tên đang tham chiếu |
| `[job]/qs-lumberjack` | Đốn Gỗ x2 | `client/x2.lua:4` | Thiếu `map-ic-wood.png`; tạo đúng tên đang tham chiếu |
| `[job]/0r-farming-v2` | Nông Trại x2 | `core/x2/client.lua:4` | Thiếu `map-ic-farming.png`; tạo đúng tên đang tham chiếu |
| `[job]/17mov_GarbageCollector` | Chở Rác x2 | `client/x2.lua:4` | Thiếu `map-ic-garbage.png`; tạo đúng tên đang tham chiếu |
| `[job]/0r-fishingv2` | Câu Cá & Lặn x2 | `client/x2.lua:4` | Thiếu `map-ic-fishing.png`; tạo đúng tên đang tham chiếu |
| `[job]/gta5vn_busjob` | Bus Job x2 | `config.lua:80`; `client/impl/x2timer.impl.lua:34` | Thiếu `map-ic-bus.png`; tạo đúng tên đang tham chiếu |
| `[job]/gta5vn_constructor` | Bê Gạch x2 | `config.lua:106`; `client/impl/x2timer.impl.lua:36` | `map-ic-construction-bricks.png` có và hợp lệ |
| `[job]/gta5vn_moneywash` | Rửa Tiền | `config.lua:68`; `client/impl/eventtimer.impl.lua:34` | `map-ic-money-laundering.png` có và hợp lệ |
| `[job]/gta5vn_graverobbery` | Trộm Mộ | `server/impl/GraveRobbery.impl.lua:6,78` | `map-ic-grave-thief.png` có và hợp lệ |
| `[job]/gta5vn_tromcho` | Trộm Chó | `server/impl/DogSpawning.impl.lua:6,316` | `map-ic-dog-thief-v3.png` có và hợp lệ |
| `[job]/gta5vn_newspaper` | Giao Báo x2 | `cl_x2.lua:4` | `bao_icon.webp` có và hợp lệ |
| `[prison]/rcore_prison` | Thời Gian Thụ Án; Biệt Giam | `modules/base/client/services/cl-se-prisoner.lua:3-9,215-230` | Cả hai dùng `map-ic-jail-prisoner.png`, có và hợp lệ |
| `[codev]/gta5vn_addons` | EXP x2/x4; Thuê Xe; Thuê Thuyền; cảnh báo bỏ phương tiện thuê | `config.lua:187-200,284-390`; `client/impl/EXP.impl.lua:17-24`; `client/impl/Rental.impl.lua:530-560` | EXP và 8 ảnh model thuê đã đủ; cảnh báo ban đầu chỉ `⚠`, bổ sung `rental-abandon-warning.png` qua `iconUrl` |

Tám ảnh model thuê đã kiểm tra: `vehicle/panto.webp`, `vehicle/asea.webp`, `vehicle/primo.webp`, `vehicle/felon.webp`, `vehicle/faggio.webp`, `vehicle/dinghy.webp`, `vehicle/seashark.webp`, `vehicle/jetmax.webp`. EXP dùng `inventory/exp_x2.webp` và `inventory/exp_x4.webp`.

HUD `[codev]/codem-supreme-hud/client/hud/eventtimers.lua:76-105` tạo 4 demo text-only: `demo_pvp` (PVP), `demo_xitson` (Xịt Sơn), `demo_xitson2` (Đào Đá x6 EXP), `demo_xitson3` (Trộm Mộ x10 EXP). Không thay đổi những demo này.

## Bộ ảnh đã xuất

| File cuối trong `images/` | Nội dung thiết kế theo resource |
|---|---|
| `parkour.png` | Vận động viên vượt chướng ngại vật; huy hiệu đỏ |
| `map-ic-mining.png` | Cuốc khai thác và khối quặng; huy hiệu xanh |
| `map-ic-wood.png` | Rìu và khúc gỗ; huy hiệu xanh |
| `map-ic-farming.png` | Bông lúa, mầm cây và đất trồng; huy hiệu xanh |
| `map-ic-garbage.png` | Thùng rác và túi rác; huy hiệu xanh |
| `map-ic-fishing.png` | Cá và kính lặn cho event kết hợp; huy hiệu xanh |
| `map-ic-bus.png` | Xe buýt thành phố; huy hiệu xanh |
| `rental-abandon-warning.png` | Xe thuê và tam giác cảnh báo; huy hiệu đỏ |

Prompt chi tiết: [`prompts.json`](prompts.json). Ánh xạ nguồn ảnh tạo và tên đích: [`assets.json`](assets.json). Kết quả xuất: [`export-results.json`](export-results.json). Audit độc lập đọc trực tiếp file cuối và xác nhận metadata dưới đây; đánh giá render trên trình duyệt do luồng kiểm tra UI chính thực hiện riêng.

| File | Byte | SHA-256 |
|---|---:|---|
| `parkour.png` | 111091 | `48bffb9611c56fc92213cd23a9beb7d7813749a56b44d6b7b8acc10fbb19615d` |
| `map-ic-mining.png` | 146475 | `6d3814716496422c1e1a760ff35724c459bf95f4c7af17c242ccb70b653b9371` |
| `map-ic-wood.png` | 135410 | `91864c5191153eb4857125cff51b1aa9d3ab51c3a99948c055832d811eef869b` |
| `map-ic-farming.png` | 127515 | `c09ee8fcaa37714b9972f2ae8b3850fca4114bf2de2f28d80df100075d1a1539` |
| `map-ic-garbage.png` | 134425 | `546cdcd12f6c5e0883bb2c7c02026d2ed5f5566d302db745c3636161298549b0` |
| `map-ic-fishing.png` | 141611 | `4e7a7bacb90b38ffb64c6c34d21eeda825c3dd29a9eb0e3c6a044ba0cf00903d` |
| `map-ic-bus.png` | 138773 | `1d3387a493bb4a83b268355973463fcdfb88e60af2b4efc369eabcbb83abd7b9` |
| `rental-abandon-warning.png` | 124010 | `646506716664d3c9c49ca2c7123ede877cc18001c4204d96a70670fad6231a05` |

## Tích hợp code và rollback

Chỉ thay đổi 4 file dưới đây, tổng cộng 4 dòng thêm / 2 dòng bỏ so với snapshot trước chỉnh sửa của task. Đã giữ kiểu newline và EOF, không gộp thay đổi có sẵn của người dùng vào kết quả task.

| File tích hợp | Thay đổi | Snapshot trước chỉnh sửa |
|---|---|---|
| `[minigame]/gta5vn_parkour/config.lua:22` | `Config.EventTimer.icon` thành URL `images/parkour.png` | `backups/hud-contract/parkour-config.lua` |
| `[minigame]/gta5vn_parkour/client/client.lua:137` | Truyền `iconUrl = Config.EventTimer.icon` | `backups/hud-contract/parkour-client.lua` |
| `[codev]/gta5vn_addons/config.lua:390` | Thêm `abandonWarning.iconUrl` trỏ `images/rental-abandon-warning.png` | `backups/hud-contract/addons-config.lua` |
| `[codev]/gta5vn_addons/client/impl/Rental.impl.lua:560` | Truyền `iconUrl = cfg.iconUrl` cho timer cảnh báo | `backups/hud-contract/rental-client.lua` |

Snapshot tại `D:/DecryptServer/GrandRPImage/.eventtimer-work-20260911/backups/hud-contract/`. Đã kiểm SHA-256 snapshot trước sửa. Khi rollback phải kiểm tra thay đổi mới phát sinh rồi chỉ đảo 4 thay đổi của task; không ghi đè mù snapshot nếu file đã được sửa tiếp.

## Kiểm chứng và giới hạn

Đã thực hiện:

- Tìm toàn workspace trong Lua/JS/TS/HTML và trace config → caller → HUD `iconUrl`; đọc manifest các resource liên quan để xác minh file caller được nạp.
- Kiểm tra tồn tại và Pillow `Image.verify()` cho 17 file ảnh sẵn có trong phạm vi: 5 PNG job/prison, báo, Skyfall, 2 EXP và 8 model thuê. Tất cả hợp lệ.
- Agent tích hợp báo PASS `luac -p` cả 4 file với Lua 5.4.6, `git diff --check`, đối chiếu byte với snapshot cộng đúng những replacement dự kiến.
- Audit độc lập PASS cả 8 PNG mới: giải mã đầy đủ, PNG 256×256 RGBA, alpha cực trị 0–255 và alpha 4 góc đều bằng 0; đã tính dung lượng và SHA-256 trực tiếp từ file cuối.
- Audit độc lập PASS toàn bộ 25 file ảnh gameplay: URL trong 15 resource khớp chính xác đường dẫn file local, kể cả chữ hoa/thường; tất cả giải mã hợp lệ. Sáu job không cần sửa code vì đã tham chiếu đúng tên ảnh mới.
- Review độc lập diff của 4 file Lua so với snapshot trước task: đúng 2 replacement Parkour và 2 dòng bổ sung `iconUrl` cho cảnh báo thuê xe, không thấy thay đổi ngoài mục tiêu trong diff này.

Giới hạn trạng thái:

- Luồng chính đã kiểm tra `preview.html` bằng Chrome ở 1280×720 và 1920×1080, cả nền HUD tối và sáng. Fixture dùng CSS cùng trình nhận thông điệp EventTimer hiện tại của HUD; 16/16 ảnh tải thành công (8 gallery ở 128 px + 8 HUD ở 30 px), kích thước DOM của mọi icon HUD là 30×30, không tràn ngang. Đã quan sát timer đang chạy và trạng thái 00:00:00, sau đó thử đặt lại timer thành công. Font hệ thống thay font game trong fixture; đây không phải FiveM live.
- Tab và HTTP server kiểm tra cục bộ đã đóng, viewport đã khôi phục. Mở trực tiếp [preview.html](preview.html) để xem lại ảnh và mẫu HUD.
- Đã đánh giá theo `hermes-self-improvement`: thông tin lần này là dữ kiện riêng của task, lưu tại báo cáo và bộ prompt; không sửa skill hoặc mở rộng quy tắc/quyền hạn chung.
- Chưa publish/push lên GitHub, chưa restart và chưa kiểm chứng hiển thị FiveM live. URL trong code cần ảnh trên nhánh remote tương ứng trước khi client live tải được ảnh mới.
