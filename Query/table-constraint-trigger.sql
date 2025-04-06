-- =================================================================================
-- I. TẠO BẢNG (CREATE TABLES) - PostgreSQL Syntax
-- =================================================================================

-- 1.1 Bảng thi_sinh: Lưu thông tin cá nhân của thí sinh
CREATE TABLE  thi_sinh (
    cccd char(12) PRIMARY KEY,          -- Khóa chính: Số Căn cước công dân
    ho_ten varchar(50) NOT NULL,       -- Họ và tên đầy đủ
    gioi_tinh varchar(10),             -- Giới tính (Nam/Nữ)
    ngay_sinh date,                    -- Ngày sinh
    dan_toc varchar(20),              -- Dân tộc
    dia_chi_thuong_tru varchar(200),  -- Địa chỉ thường trú
    dia_chi_lien_lac varchar(200),    -- Địa chỉ liên lạc
    truong_thpt_ma_tinh int,          -- Mã tỉnh của trường THPT lớp 12 (FK tới truong_thpt)
    ma_truong_thpt int,                -- Mã trường THPT lớp 12 (FK tới truong_thpt)
    email varchar(50),                 -- Địa chỉ email
    so_dien_thoai char(10),            -- Số điện thoại
    khu_vuc_uu_tien char(3),           -- Khu vực ưu tiên (FK tới truong_thpt hoặc bảng khu vực riêng)
    doi_tuong_uu_tien int              -- Đối tượng ưu tiên (0-7)
);

-- 1.2 Bảng tai_khoan_thi_sinh: Lưu thông tin đăng nhập của thí sinh
CREATE TABLE tai_khoan_thi_sinh (
    cccd char(12) PRIMARY KEY,      -- Khóa chính, cũng là khóa ngoại tới thi_sinh
    mat_khau varchar(100) NOT NULL  -- Mật khẩu đăng nhập (nên được hash trước khi lưu, varchar(100) để đủ chỗ cho hash)
);


-- 1.3 Bảng truong_thpt: Lưu thông tin các trường THPT
CREATE TABLE truong_thpt (
    ma_truong int PRIMARY KEY,         -- Khóa chính: Mã trường THPT
    ten_truong_thpt varchar(100) NOT NULL, -- Tên trường THPT
    ma_tinh_thanh_pho int,             -- Mã tỉnh/thành phố
    tinh_thanh_pho varchar(20),      -- Tên tỉnh/thành phố
    dia_chi varchar(200),             -- Địa chỉ trường
    khu_vuc_xet_tuyen varchar(3)     -- Khu vực xét tuyển của trường ('1', '2', '2NT', '3')
);



-- 2.1 Bảng ho_so_du_thi: Lưu thông tin hồ sơ đăng ký dự thi của thí sinh cho mỗi đợt
CREATE TABLE ho_so_du_thi
(
    ma_ho_so_du_thi char(15) PRIMARY KEY, -- Khóa chính: Mã hồ sơ dự thi (có thể là số báo danh)
    cccd varchar(12) NOT NULL,           -- Khóa ngoại tới thi_sinh
    dia_diem_du_thi varchar(100),       -- Địa điểm dự thi thí sinh đăng ký
    tinh_trang_thanh_toan varchar(20) DEFAULT 'chua_thanh_toan', -- Tình trạng thanh toán lệ phí ('chua_thanh_toan', 'da_thanh_toan')
    le_phi_thi numeric(10, 2),          -- Số tiền lệ phí thi
    thoi_gian_thanh_toan_le_phi_thi timestamp, -- Thời gian hoàn tất thanh toán (timestamp không có timezone)
    dot_thi int NOT NULL,                -- Đợt thi (1 hoặc 2)
    CONSTRAINT uq_hoso_thisinh_dotthi UNIQUE (cccd, dot_thi) -- Ràng buộc Composite Key
);



-- 2.2 Bảng ket_qua_thi: Lưu kết quả thi ĐGNL của thí sinh cho mỗi đợt
CREATE TABLE ket_qua_thi (
    cccd varchar(12) NOT NULL,           -- Khóa ngoại tới thi_sinh
    dot_thi int NOT NULL,                -- Đợt thi (1 hoặc 2)
    diem_thanh_phan_tieng_viet int,    -- Điểm thành phần Tiếng Việt (max 300)
    diem_thanh_phan_tieng_anh int,     -- Điểm thành phần Tiếng Anh (max 300)
    diem_thanh_phan_toan_hoc int,      -- Điểm thành phần Toán học (max 300)
    diem_thanh_phan_logic_phan_tich_so_lieu int, -- Điểm thành phần Logic & Phân tích số liệu (max 120)
    diem_thanh_phan_suy_luan_khoa_hoc int, -- Điểm thành phần Suy luận khoa học (max 180)
    ket_qua_thi int,                   -- Tổng điểm thi (max 1200), có thể tính bằng trigger
    PRIMARY KEY (cccd, dot_thi)          -- Khóa chính tổng hợp
);



-- 2.3 Bảng ho_so_xet_tuyen: Lưu hồ sơ đăng ký xét tuyển của thí sinh
CREATE TABLE select * from ho_so_xet_tuyen where (khu_vuc_uu_tien ='2') (
    ma_ho_so_xet_tuyen char(10) PRIMARY KEY, -- Khóa chính: Mã hồ sơ xét tuyển
    cccd char(12) NOT NULL UNIQUE,       -- Khóa ngoại tới thi_sinh, UNIQUE để đảm bảo mỗi TS chỉ có 1 HSXT
    diem_thi int,                      -- Điểm thi ĐGNL cao nhất dùng để xét (lấy từ ket_qua_thi)
    khu_vuc_uu_tien char(3),           -- Khu vực ưu tiên (lấy từ thi_sinh)
    doi_tuong_uu_tien int,             -- Đối tượng ưu tiên (lấy từ thi_sinh)
    diem_xet_tuyen double precision,   -- Điểm xét tuyển (tính bằng trigger/function)
    le_phi_xet_tuyen numeric(12, 2)    -- Lệ phí xét tuyển (tính bằng trigger dựa trên số NV)
);

-- 3.1 Bảng nganh_dao_tao_dai_hoc: Lưu thông tin các ngành đào tạo
CREATE TABLE select * from nganh_dao_tao_dai_hoc (
    ma_nganh varchar(30) PRIMARY KEY,   -- Khóa chính: Mã ngành đào tạo
    ten_nganh varchar(100) NOT NULL,  -- Tên ngành đào tạo
    ma_truong_khoa char(3),           -- Mã trường/khoa quản lý ngành
    ten_truong_khoa varchar(100),     -- Tên trường/khoa quản lý ngành
    chi_tieu_tuyen_sinh int,         -- Chỉ tiêu tuyển sinh cho phương thức ĐGNL
    ky_nang_tieng_viet int,            -- Yêu cầu kỹ năng Tiếng Việt (0: Thấp, 1: TB, 2: Cao) - tham khảo
    ky_nang_tieng_anh int,             -- Yêu cầu kỹ năng Tiếng Anh (0/1/2) - tham khảo
    ky_nang_toan_hoc int,              -- Yêu cầu kỹ năng Toán học (0/1/2) - tham khảo
    ky_nang_logic_phan_tich_so_lieu int, -- Yêu cầu kỹ năng Logic (0/1/2) - tham khảo
    ky_nang_suy_luan_khoa_hoc int,     -- Yêu cầu kỹ năng Suy luận KH (0/1/2) - tham khảo
    diem_chuan_nam_truoc int           -- Điểm chuẩn trúng tuyển của năm trước (tham khảo)
);


-- 2.4 Bảng nguyen_vong_xet_tuyen: Lưu các nguyện vọng xét tuyển của thí sinh
CREATE TABLE nguyen_vong_xet_tuyen (
    ma_ho_so_xet_tuyen char(10) NOT NULL, -- Khóa ngoại tới ho_so_xet_tuyen
    cccd char(12) NOT NULL,              -- Khóa ngoại tới thi_sinh (để tiện truy vấn)
    ma_nganh varchar(30) NOT NULL,       -- Khóa ngoại tới nganh_dao_tao_dai_hoc (thay char -> varchar)
    thu_tu_nguyen_vong int NOT NULL,     -- Thứ tự nguyện vọng của thí sinh này
    diem_xet_tuyen double precision,     -- Điểm xét tuyển của hồ sơ này (copy từ ho_so_xet_tuyen để tiện xét)
    PRIMARY KEY (ma_ho_so_xet_tuyen, thu_tu_nguyen_vong), -- Khóa chính tổng hợp
    CONSTRAINT uq_nguyenvong_thisinh_nganh UNIQUE (cccd, ma_nganh) -- Đảm bảo TS không đăng ký trùng ngành
);



-- 3.2 Bảng danh_sach_du_dieu_kien_trung_tuyen: Lưu danh sách thí sinh đủ điều kiện trúng tuyển (sơ bộ)
CREATE TABLE danh_sach_du_dieu_kien_trung_tuyen (
    ma_truong char(3) NOT NULL,        -- Mã trường (FK tới nganh_dao_tao_dai_hoc)
    ma_nganh varchar(20) NOT NULL,     -- Mã ngành (FK tới nganh_dao_tao_dai_hoc, thay char -> varchar)
    cccd char(12) NOT NULL,             -- CCCD thí sinh (FK tới thi_sinh)
    diem_xet_tuyen double precision,   -- Điểm xét tuyển của thí sinh trúng tuyển vào ngành này
    PRIMARY KEY (ma_nganh, cccd)        -- Khóa chính tổng hợp (mỗi TS chỉ trúng 1 ngành trong DS này)
);



-- 3.3 Bảng tai_khoan_quan_ly_xet_tuyen: Lưu tài khoản của cán bộ xét tuyển
CREATE TABLE tai_khoan_quan_ly_xet_tuyen (
    ten_dang_nhap varchar(20) PRIMARY KEY, -- Khóa chính: Tên đăng nhập của cán bộ/đơn vị (thay char -> varchar)
    mat_khau varchar(100) NOT NULL       -- Mật khẩu đăng nhập (nên được hash, varchar(100))
);



-- 4.1 Bảng ky_nang_cua_thi_sinh: Đánh giá kỹ năng dựa trên kết quả thi
CREATE TABLE ky_nang_cua_thi_sinh (
    cccd char(12) PRIMARY KEY,              -- Khóa chính, khóa ngoại tới thi_sinh
    danh_gia_ky_nang_tieng_viet int,       -- Đánh giá kỹ năng Tiếng Việt (0: Thấp, 1: TB, 2: Cao)
    danh_gia_ky_nang_tieng_anh int,        -- Đánh giá kỹ năng Tiếng Anh (0/1/2)
    danh_gia_ky_nang_toan_hoc int,         -- Đánh giá kỹ năng Toán học (0/1/2)
    danh_gia_ky_nang_logic_phan_tich_so_lieu int, -- Đánh giá kỹ năng Logic (0/1/2)
    danh_gia_ky_nang_suy_luan_khoa_hoc int,  -- Đánh giá kỹ năng Suy luận KH (0/1/2)
    diem_thi_cao_nhat int                  -- Điểm thi ĐGNL cao nhất (lưu trữ giá trị, không phải FK)
);


-- 4.2 Bảng cac_khuyen_nghi_nganh_hoc: Lưu các ngành học được khuyến nghị cho thí sinh
CREATE TABLE cac_khuyen_nghi_nganh_hoc (
    cccd char(12) NOT NULL,             -- Khóa ngoại tới ky_nang_cua_thi_sinh
    ma_nganh varchar(20) NOT NULL,         -- Khóa ngoại tới nganh_dao_tao_dai_hoc (thay char -> varchar)
    ten_nganh varchar(100),             -- Tên ngành (lấy từ nganh_dao_tao_dai_hoc)
    thu_tu_khuyen_nghi int NOT NULL,    -- Thứ tự khuyến nghị cho thí sinh này
    PRIMARY KEY (cccd, thu_tu_khuyen_nghi) -- Khóa chính tổng hợp
    -- Có thể thêm một cột điểm tương thích (similarity score) nếu cần: diem_tuong_thich double precision
);



-- =================================================================================
-- II. TẠO RÀNG BUỘC KHÓA NGOẠI (FOREIGN KEY CONSTRAINTS) - PostgreSQL Syntax
-- =================================================================================

-- Ràng buộc cho bảng thi_sinh
ALTER TABLE thi_sinh
ADD CONSTRAINT fk_thisinh_truongthpt FOREIGN KEY (ma_truong_thpt) REFERENCES truong_thpt(ma_truong);

-- Ràng buộc cho bảng tai_khoan_thi_sinh
ALTER TABLE tai_khoan_thi_sinh
ADD CONSTRAINT fk_taikhoan_thisinh FOREIGN KEY (cccd) REFERENCES thi_sinh(cccd) ON DELETE CASCADE;

-- Ràng buộc cho bảng ho_so_du_thi
ALTER TABLE ho_so_du_thi
ADD CONSTRAINT fk_hoso_thisinh FOREIGN KEY (cccd) REFERENCES thi_sinh(cccd);

-- Ràng buộc cho bảng ket_qua_thi
ALTER TABLE ket_qua_thi
ADD CONSTRAINT fk_ketqua_thisinh FOREIGN KEY (cccd) REFERENCES thi_sinh(cccd);

-- Ràng buộc cho bảng ho_so_xet_tuyen
ALTER TABLE ho_so_xet_tuyen
ADD CONSTRAINT fk_hosoxettuyen_thisinh FOREIGN KEY (cccd) REFERENCES thi_sinh(cccd) ON DELETE CASCADE;

-- Ràng buộc cho bảng nguyen_vong_xet_tuyen
ALTER TABLE nguyen_vong_xet_tuyen
ADD CONSTRAINT fk_nguyenvong_hoso FOREIGN KEY (ma_ho_so_xet_tuyen) REFERENCES ho_so_xet_tuyen(ma_ho_so_xet_tuyen) ON DELETE CASCADE;

ALTER TABLE nguyen_vong_xet_tuyen
ADD CONSTRAINT fk_nguyenvong_thisinh FOREIGN KEY (cccd) REFERENCES thi_sinh(cccd);

ALTER TABLE nguyen_vong_xet_tuyen
ADD CONSTRAINT fk_nguyenvong_nganh FOREIGN KEY (ma_nganh) REFERENCES nganh_dao_tao_dai_hoc(ma_nganh);

-- Ràng buộc cho bảng danh_sach_du_dieu_kien_trung_tuyen
ALTER TABLE danh_sach_du_dieu_kien_trung_tuyen
ADD CONSTRAINT fk_dsddktt_nganh FOREIGN KEY (ma_nganh) REFERENCES nganh_dao_tao_dai_hoc(ma_nganh);

ALTER TABLE danh_sach_du_dieu_kien_trung_tuyen
ADD CONSTRAINT fk_dsddktt_thisinh FOREIGN KEY (cccd) REFERENCES thi_sinh(cccd);

-- Ràng buộc cho bảng ky_nang_cua_thi_sinh
ALTER TABLE ky_nang_cua_thi_sinh
ADD CONSTRAINT fk_kynang_thisinh FOREIGN KEY (cccd) REFERENCES thi_sinh(cccd) ON DELETE CASCADE;

-- Ràng buộc cho bảng cac_khuyen_nghi_nganh_hoc
ALTER TABLE cac_khuyen_nghi_nganh_hoc
ADD CONSTRAINT fk_khuyennghi_kynang FOREIGN KEY (cccd) REFERENCES ky_nang_cua_thi_sinh(cccd) ON DELETE CASCADE;

ALTER TABLE cac_khuyen_nghi_nganh_hoc
ADD CONSTRAINT fk_khuyennghi_nganh FOREIGN KEY (ma_nganh) REFERENCES nganh_dao_tao_dai_hoc(ma_nganh);

-- =================================================================================
-- III. TẠO RÀNG BUỘC KIỂM TRA (CHECK CONSTRAINTS) - PostgreSQL Syntax
-- =================================================================================

-- Ràng buộc CHECK cho bảng thi_sinh
ALTER TABLE thi_sinh
ADD CONSTRAINT chk_thisinh_gioitinh CHECK (gioi_tinh IN ('Nam', 'Nữ'));

ALTER TABLE thi_sinh
ADD CONSTRAINT chk_thisinh_dienthoai CHECK (so_dien_thoai ~ '^[0-9]+$'); -- Kiểm tra SĐT chỉ chứa số (Regex PostgreSQL)

ALTER TABLE thi_sinh
ADD CONSTRAINT chk_thisinh_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'); -- Kiểm tra định dạng email cơ bản (Regex PostgreSQL)

ALTER TABLE thi_sinh
ADD CONSTRAINT chk_thisinh_doituonguutien CHECK (doi_tuong_uu_tien BETWEEN 0 AND 7);-- 'Đối tượng ưu tiên phải nằm trong khoảng từ 0 đến 7.';

-- Ràng buộc CHECK cho bảng truong_thpt
ALTER TABLE truong_thpt
ADD CONSTRAINT chk_truongthpt_khuvuc CHECK (khu_vuc_xet_tuyen IN ('1', '2', '2NT', '3'));-- 'Khu vực xét tuyển của trường THPT phải là 1, 2, 2NT hoặc 3.';

-- Ràng buộc CHECK cho bảng ho_so_du_thi
ALTER TABLE ho_so_du_thi
ADD CONSTRAINT chk_hoso_thanhtoan CHECK (tinh_trang_thanh_toan IN ('chua_thanh_toan', 'da_thanh_toan'));-- 'Tình trạng thanh toán phải là chua_thanh_toan hoặc da_thanh_toan.';

ALTER TABLE ho_so_du_thi
ADD CONSTRAINT chk_hoso_dotthi CHECK (dot_thi IN (1, 2));--'Đợt thi phải là 1 hoặc 2.';

-- Ràng buộc CHECK cho bảng ket_qua_thi
ALTER TABLE ket_qua_thi
ADD CONSTRAINT chk_ketqua_diem_viet CHECK (diem_thanh_phan_tieng_viet BETWEEN 0 AND 300);--Điểm thành phần Tiếng Việt phải từ 0 đến 300.';

ALTER TABLE ket_qua_thi
ADD CONSTRAINT chk_ketqua_diem_anh CHECK (diem_thanh_phan_tieng_anh BETWEEN 0 AND 300);-- 'Điểm thành phần Tiếng Anh phải từ 0 đến 300.';

ALTER TABLE ket_qua_thi
ADD CONSTRAINT chk_ketqua_diem_toan CHECK (diem_thanh_phan_toan_hoc BETWEEN 0 AND 300);-- 'Điểm thành phần Toán học phải từ 0 đến 300.';

ALTER TABLE ket_qua_thi
ADD CONSTRAINT chk_ketqua_diem_logic CHECK (diem_thanh_phan_logic_phan_tich_so_lieu BETWEEN 0 AND 120);-- 'Điểm thành phần Logic và Phân tích số liệu phải từ 0 đến 120.';

ALTER TABLE ket_qua_thi
ADD CONSTRAINT chk_ketqua_diem_khoahoc CHECK (diem_thanh_phan_suy_luan_khoa_hoc BETWEEN 0 AND 180);-- 'Điểm thành phần Suy luận khoa học phải từ 0 đến 180.';

ALTER TABLE ket_qua_thi
ADD CONSTRAINT chk_ketqua_tongdiem CHECK (ket_qua_thi BETWEEN 0 AND 1200);--'Tổng điểm thi phải từ 0 đến 1200.';

ALTER TABLE ket_qua_thi
ADD CONSTRAINT chk_ketqua_dotthi CHECK (dot_thi IN (1, 2));-- 'Đợt thi của kết quả phải là 1 hoặc 2.';

-- Ràng buộc CHECK cho bảng nganh_dao_tao_dai_hoc
ALTER TABLE nganh_dao_tao_dai_hoc
ADD CONSTRAINT chk_nganh_kynang_viet CHECK (ky_nang_tieng_viet BETWEEN 0 AND 2);--'Đánh giá yêu cầu kỹ năng Tiếng Việt phải là 0, 1 hoặc 2.';
ALTER TABLE nganh_dao_tao_dai_hoc ADD CONSTRAINT chk_nganh_kynang_anh CHECK (ky_nang_tieng_anh BETWEEN 0 AND 2);
ALTER TABLE nganh_dao_tao_dai_hoc ADD CONSTRAINT chk_nganh_kynang_toan CHECK (ky_nang_toan_hoc BETWEEN 0 AND 2);
ALTER TABLE nganh_dao_tao_dai_hoc ADD CONSTRAINT chk_nganh_kynang_logic CHECK (ky_nang_logic_phan_tich_so_lieu BETWEEN 0 AND 2);
ALTER TABLE nganh_dao_tao_dai_hoc ADD CONSTRAINT chk_nganh_kynang_khoahoc CHECK (ky_nang_suy_luan_khoa_hoc BETWEEN 0 AND 2);


ALTER TABLE nguyen_vong_xet_tuyen
ADD CONSTRAINT chk_nguyenvong_thutu CHECK (thu_tu_nguyen_vong > 0);-- 'Thứ tự nguyện vọng phải là số dương.';

-- Ràng buộc CHECK cho bảng ky_nang_cua_thi_sinh
ALTER TABLE ky_nang_cua_thi_sinh
ADD CONSTRAINT chk_kynang_danhgia_viet CHECK (danh_gia_ky_nang_tieng_viet BETWEEN 0 AND 2);
--'Đánh giá kỹ năng phải là 0, 1 hoặc 2.';
ALTER TABLE ky_nang_cua_thi_sinh ADD CONSTRAINT chk_kynang_danhgia_anh CHECK (danh_gia_ky_nang_tieng_anh BETWEEN 0 AND 2);
ALTER TABLE ky_nang_cua_thi_sinh ADD CONSTRAINT chk_kynang_danhgia_toan CHECK (danh_gia_ky_nang_toan_hoc BETWEEN 0 AND 2);
ALTER TABLE ky_nang_cua_thi_sinh ADD CONSTRAINT chk_kynang_danhgia_logic CHECK (danh_gia_ky_nang_logic_phan_tich_so_lieu BETWEEN 0 AND 2);
ALTER TABLE ky_nang_cua_thi_sinh ADD CONSTRAINT chk_kynang_danhgia_khoahoc CHECK (danh_gia_ky_nang_suy_luan_khoa_hoc BETWEEN 0 AND 2);


-- =================================================================================
-- IV. TẠO TRIGGER - PostgreSQL Syntax (Functions and Triggers)
-- =================================================================================

-- Trigger Function: Tự động tính tổng điểm khi điểm thành phần thay đổi
CREATE OR REPLACE FUNCTION func_TinhTongDiemThi()
RETURNS TRIGGER AS $$
BEGIN
    -- Chỉ tính lại khi INSERT hoặc UPDATE các cột điểm thành phần
    IF TG_OP = 'INSERT' OR (TG_OP = 'UPDATE' AND (
            NEW.diem_thanh_phan_tieng_viet IS DISTINCT FROM OLD.diem_thanh_phan_tieng_viet OR
            NEW.diem_thanh_phan_tieng_anh IS DISTINCT FROM OLD.diem_thanh_phan_tieng_anh OR
            NEW.diem_thanh_phan_toan_hoc IS DISTINCT FROM OLD.diem_thanh_phan_toan_hoc OR
            NEW.diem_thanh_phan_logic_phan_tich_so_lieu IS DISTINCT FROM OLD.diem_thanh_phan_logic_phan_tich_so_lieu OR
            NEW.diem_thanh_phan_suy_luan_khoa_hoc IS DISTINCT FROM OLD.diem_thanh_phan_suy_luan_khoa_hoc
        ))
    THEN
        NEW.ket_qua_thi := COALESCE(NEW.diem_thanh_phan_tieng_viet, 0) +
                           COALESCE(NEW.diem_thanh_phan_tieng_anh, 0) +
                           COALESCE(NEW.diem_thanh_phan_toan_hoc, 0) +
                           COALESCE(NEW.diem_thanh_phan_logic_phan_tich_so_lieu, 0) +
                           COALESCE(NEW.diem_thanh_phan_suy_luan_khoa_hoc, 0);
    END IF;
    RETURN NEW; -- Trả về bản ghi mới (hoặc đã sửa) để INSERT/UPDATE
END;
$$ LANGUAGE plpgsql;

-- Trigger: Kích hoạt function trên bảng ket_qua_thi (BEFORE INSERT OR UPDATE)
CREATE TRIGGER tg_TinhTongDiemThi
BEFORE INSERT OR UPDATE ON ket_qua_thi
FOR EACH ROW
EXECUTE FUNCTION func_TinhTongDiemThi();


-- ---

-- Trigger Function: Cập nhật điểm thi cao nhất và đánh giá kỹ năng khi kết quả thi thay đổi
CREATE OR REPLACE FUNCTION func_CapNhatKyNangVaDiemCaoNhat()
RETURNS TRIGGER AS $$
DECLARE
    v_cccd char(12);
    v_diem_cao_nhat int;
    v_diem_viet int;
    v_diem_anh int;
    v_diem_toan int;
    v_diem_logic int;
    v_diem_kh int;
    v_danh_gia_viet int;
    v_danh_gia_anh int;
    v_danh_gia_toan int;
    v_danh_gia_logic int;
    v_danh_gia_kh int;
BEGIN
    -- Xác định cccd bị ảnh hưởng
    IF TG_OP = 'DELETE' THEN
        v_cccd := OLD.cccd;
    ELSE -- INSERT or UPDATE
        v_cccd := NEW.cccd;
    END IF;

    -- Tìm kết quả cao nhất mới của thí sinh này
    SELECT
        MAX(ket_qua_thi),
        MAX(CASE WHEN rnk = 1 THEN diem_thanh_phan_tieng_viet ELSE NULL END),
        MAX(CASE WHEN rnk = 1 THEN diem_thanh_phan_tieng_anh ELSE NULL END),
        MAX(CASE WHEN rnk = 1 THEN diem_thanh_phan_toan_hoc ELSE NULL END),
        MAX(CASE WHEN rnk = 1 THEN diem_thanh_phan_logic_phan_tich_so_lieu ELSE NULL END),
        MAX(CASE WHEN rnk = 1 THEN diem_thanh_phan_suy_luan_khoa_hoc ELSE NULL END)
    INTO
        v_diem_cao_nhat, v_diem_viet, v_diem_anh, v_diem_toan, v_diem_logic, v_diem_kh
    FROM (
        SELECT *, RANK() OVER (ORDER BY ket_qua_thi DESC, dot_thi DESC) as rnk -- Ưu tiên đợt thi mới hơn nếu điểm bằng nhau
        FROM ket_qua_thi
        WHERE cccd = v_cccd
    ) AS ranked_results
    WHERE rnk = 1; -- Chỉ lấy dòng có điểm cao nhất

    -- Nếu không còn kết quả nào (sau DELETE), xóa bản ghi kỹ năng
    IF v_diem_cao_nhat IS NULL THEN
        DELETE FROM ky_nang_cua_thi_sinh WHERE cccd = v_cccd;
    ELSE
        -- Tính toán đánh giá kỹ năng
        v_danh_gia_viet := CASE WHEN v_diem_viet >= (300.0 * 2 / 3) THEN 2 WHEN v_diem_viet >= (300.0 / 3) THEN 1 ELSE 0 END;
        v_danh_gia_anh  := CASE WHEN v_diem_anh  >= (300.0 * 2 / 3) THEN 2 WHEN v_diem_anh  >= (300.0 / 3) THEN 1 ELSE 0 END;
        v_danh_gia_toan := CASE WHEN v_diem_toan >= (300.0 * 2 / 3) THEN 2 WHEN v_diem_toan >= (300.0 / 3) THEN 1 ELSE 0 END;
        v_danh_gia_logic:= CASE WHEN v_diem_logic >= (120.0 * 2 / 3) THEN 2 WHEN v_diem_logic >= (120.0 / 3) THEN 1 ELSE 0 END;
        v_danh_gia_kh   := CASE WHEN v_diem_kh >= (180.0 * 2 / 3) THEN 2 WHEN v_diem_kh >= (180.0 / 3) THEN 1 ELSE 0 END;

        -- Cập nhật hoặc Thêm mới bản ghi kỹ năng (Upsert)
        INSERT INTO ky_nang_cua_thi_sinh (cccd, diem_thi_cao_nhat, danh_gia_ky_nang_tieng_viet, danh_gia_ky_nang_tieng_anh, danh_gia_ky_nang_toan_hoc, danh_gia_ky_nang_logic_phan_tich_so_lieu, danh_gia_ky_nang_suy_luan_khoa_hoc)
        VALUES (v_cccd, v_diem_cao_nhat, v_danh_gia_viet, v_danh_gia_anh, v_danh_gia_toan, v_danh_gia_logic, v_danh_gia_kh)
        ON CONFLICT (cccd) DO UPDATE SET
            diem_thi_cao_nhat = EXCLUDED.diem_thi_cao_nhat,
            danh_gia_ky_nang_tieng_viet = EXCLUDED.danh_gia_ky_nang_tieng_viet,
            danh_gia_ky_nang_tieng_anh = EXCLUDED.danh_gia_ky_nang_tieng_anh,
            danh_gia_ky_nang_toan_hoc = EXCLUDED.danh_gia_ky_nang_toan_hoc,
            danh_gia_ky_nang_logic_phan_tich_so_lieu = EXCLUDED.danh_gia_ky_nang_logic_phan_tich_so_lieu,
            danh_gia_ky_nang_suy_luan_khoa_hoc = EXCLUDED.danh_gia_ky_nang_suy_luan_khoa_hoc;

        -- Cập nhật lại điểm thi trong hồ sơ xét tuyển
        UPDATE ho_so_xet_tuyen
        SET diem_thi = v_diem_cao_nhat
        WHERE cccd = v_cccd;

    END IF;

    RETURN NULL; -- AFTER trigger nên trả về NULL
END;
$$ LANGUAGE plpgsql;

-- Trigger: Kích hoạt function trên bảng ket_qua_thi (AFTER INSERT, UPDATE, DELETE)
CREATE TRIGGER tg_CapNhatKyNangVaDiemCaoNhat
AFTER INSERT OR UPDATE OR DELETE ON ket_qua_thi
FOR EACH ROW
EXECUTE FUNCTION func_CapNhatKyNangVaDiemCaoNhat();


-- ---

-- Trigger Function: Tự động cập nhật thông tin ưu tiên và điểm thi khi tạo hồ sơ xét tuyển


-- Trigger: Kích hoạt function trên bảng ho_so_xet_tuyen (BEFORE INSERT)



-- ---

-- Function: Tính điểm ưu tiên (Ví dụ - Cần logic chuẩn)
CREATE OR REPLACE FUNCTION func_TinhDiemUuTien(
    p_diem_thi int,
    p_khu_vuc char(3),
    p_doi_tuong int
)
RETURNS double precision AS $$
DECLARE
    v_diem_ut_kv double precision := 0;
    v_diem_ut_dt double precision := 0;
    v_tong_diem_ut double precision := 0;
BEGIN
    -- Tính điểm ưu tiên khu vực 
    v_diem_ut_kv := CASE p_khu_vuc
                        WHEN '1' THEN 30
                        WHEN '2NT' THEN 20
                        WHEN '2' THEN 10
                        ELSE 0
                    END;

    -- Tính điểm ưu tiên đối tượng (ví dụ)
    v_diem_ut_dt := CASE
                        WHEN p_doi_tuong BETWEEN 1 AND 4 THEN 80
                        WHEN p_doi_tuong BETWEEN 5 AND 7 THEN 40
                        ELSE 0
                    END;

    v_tong_diem_ut := v_diem_ut_kv + v_diem_ut_dt;

    -- Áp dụng công thức giảm điểm ưu tiên nếu điểm thi cao (theo footnote)
    IF COALESCE(p_diem_thi, 0) >= 900 THEN
       v_tong_diem_ut := v_tong_diem_ut * (1200.0 - COALESCE(p_diem_thi, 0)) / 300.0;
       -- Đảm bảo điểm ưu tiên không âm nếu điểm thi > 1200 (dù không nên xảy ra)
       IF v_tong_diem_ut < 0 THEN v_tong_diem_ut := 0; END IF;
    END IF;

    RETURN v_tong_diem_ut;
END;
$$ LANGUAGE plpgsql;



-- Trigger Function: Tính điểm xét tuyển khi thông tin liên quan thay đổi
CREATE OR REPLACE FUNCTION func_TinhDiemXetTuyen()
RETURNS TRIGGER AS $$
BEGIN
    -- Chỉ tính lại khi INSERT hoặc UPDATE các cột liên quan
    IF TG_OP = 'INSERT' OR (TG_OP = 'UPDATE' AND (
            NEW.diem_thi IS DISTINCT FROM OLD.diem_thi OR
            NEW.khu_vuc_uu_tien IS DISTINCT FROM OLD.khu_vuc_uu_tien OR
            NEW.doi_tuong_uu_tien IS DISTINCT FROM OLD.doi_tuong_uu_tien
        ))
    THEN
        NEW.diem_xet_tuyen := COALESCE(NEW.diem_thi, 0) + func_TinhDiemUuTien(NEW.diem_thi, NEW.khu_vuc_uu_tien, NEW.doi_tuong_uu_tien);

        -- Cập nhật điểm xét tuyển trong bảng nguyện vọng tương ứng (cần trigger riêng AFTER UPDATE)
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger: Kích hoạt function tính điểm XÉT TUYỂN trên bảng ho_so_xet_tuyen (BEFORE INSERT OR UPDATE)
CREATE TRIGGER tg_TinhDiemXetTuyen
BEFORE INSERT OR UPDATE ON ho_so_xet_tuyen
FOR EACH ROW
EXECUTE FUNCTION func_TinhDiemXetTuyen();



-- Trigger Function: Cập nhật điểm xét tuyển vào nguyện vọng sau khi hồ sơ thay đổi
CREATE OR REPLACE FUNCTION func_CapNhatDiemXetTuyenNguyenVong()
RETURNS TRIGGER AS $$
BEGIN
    -- Chỉ chạy khi điểm xét tuyển thực sự thay đổi
    IF NEW.diem_xet_tuyen IS DISTINCT FROM OLD.diem_xet_tuyen THEN
         UPDATE nguyen_vong_xet_tuyen nvxt
         SET diem_xet_tuyen = NEW.diem_xet_tuyen
         WHERE nvxt.ma_ho_so_xet_tuyen = NEW.ma_ho_so_xet_tuyen;
    END IF;
    RETURN NULL; -- AFTER trigger
END;
$$ LANGUAGE plpgsql;

-- Trigger: Kích hoạt function cập nhật NV sau khi hồ sơ được cập nhật điểm
CREATE TRIGGER tg_CapNhatDiemXetTuyenNguyenVong
AFTER UPDATE ON ho_so_xet_tuyen
FOR EACH ROW
WHEN (OLD.diem_xet_tuyen IS DISTINCT FROM NEW.diem_xet_tuyen) -- Chỉ kích hoạt khi điểm thay đổi
EXECUTE FUNCTION func_CapNhatDiemXetTuyenNguyenVong();



-- ---

-- Trigger Function: Tính lệ phí xét tuyển khi số lượng nguyện vọng thay đổi
CREATE OR REPLACE FUNCTION func_TinhLePhiXetTuyen()
RETURNS TRIGGER AS $$
DECLARE
    v_ma_ho_so char(10);
    v_so_luong_nv int;
    v_le_phi numeric(12, 2);
BEGIN
    IF TG_OP = 'INSERT' THEN
        v_ma_ho_so := NEW.ma_ho_so_xet_tuyen;
    ELSIF TG_OP = 'DELETE' THEN
        v_ma_ho_so := OLD.ma_ho_so_xet_tuyen;
    END IF;

    -- Đếm số nguyện vọng hiện tại của hồ sơ đó
    SELECT COUNT(*) INTO v_so_luong_nv
    FROM nguyen_vong_xet_tuyen
    WHERE ma_ho_so_xet_tuyen = v_ma_ho_so;

    -- Tính lệ phí (ví dụ 30,000 VND/nguyện vọng)
    v_le_phi := v_so_luong_nv * 30000.0;

    -- Cập nhật vào bảng ho_so_xet_tuyen
    UPDATE ho_so_xet_tuyen
    SET le_phi_xet_tuyen = v_le_phi
    WHERE ma_ho_so_xet_tuyen = v_ma_ho_so;

    RETURN NULL; -- AFTER trigger
END;
$$ LANGUAGE plpgsql;

-- Trigger: Kích hoạt function trên bảng nguyen_vong_xet_tuyen (AFTER INSERT, DELETE)
CREATE TRIGGER tg_TinhLePhiXetTuyen
AFTER INSERT OR DELETE ON nguyen_vong_xet_tuyen
FOR EACH ROW
EXECUTE FUNCTION func_TinhLePhiXetTuyen();


-- ---
CREATE OR REPLACE FUNCTION func_auto_fill_diem_xet_tuyen_nv()
RETURNS TRIGGER AS $$
DECLARE
    v_diem_xet_tuyen double precision; -- Biến để lưu điểm lấy được
BEGIN
    -- Kiểm tra xem có ma_ho_so_xet_tuyen được cung cấp không
    IF NEW.ma_ho_so_xet_tuyen IS NULL THEN
        -- Có thể bạn muốn raise lỗi ở đây nếu mã hồ sơ là bắt buộc
        RAISE EXCEPTION 'Mã hồ sơ xét tuyển không được để trống khi thêm nguyện vọng.';
        RETURN NULL; -- Ngăn chặn INSERT nếu muốn
    END IF;

    -- Truy vấn điểm xét tuyển từ bảng ho_so_xet_tuyen
    SELECT hsxt.diem_xet_tuyen
    INTO v_diem_xet_tuyen -- Lưu kết quả vào biến
    FROM ho_so_xet_tuyen hsxt
    WHERE hsxt.ma_ho_so_xet_tuyen = NEW.ma_ho_so_xet_tuyen; -- Điều kiện khớp mã hồ sơ

    -- Gán giá trị điểm vừa truy vấn được vào cột diem_xet_tuyen của bản ghi NGUYỆN VỌNG mới
    -- Nếu không tìm thấy hồ sơ (v_diem_xet_tuyen sẽ là NULL), thì cột này cũng sẽ là NULL
    NEW.diem_xet_tuyen := v_diem_xet_tuyen;

    -- Trả về bản ghi NEW đã được sửa đổi (thêm diem_xet_tuyen) để câu lệnh INSERT tiếp tục
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- Tạo trigger mới
CREATE TRIGGER tg_auto_fill_diem_xet_tuyen_nv
BEFORE INSERT ON nguyen_vong_xet_tuyen -- Kích hoạt TRƯỚC KHI chèn
FOR EACH ROW -- Áp dụng cho từng dòng được chèn
EXECUTE FUNCTION func_auto_fill_diem_xet_tuyen_nv(); -- Gọi function đã tạo

COMMENT ON TRIGGER tg_auto_fill_diem_xet_tuyen_nv ON nguyen_vong_xet_tuyen IS
'Tự động điền điểm xét tuyển từ hồ sơ tương ứng khi thêm nguyện vọng mới.';


-- ---

-- Trigger Function: Xử lý việc thay đổi thứ tự nguyện vọng (Phức tạp - Cân nhắc xử lý ở tầng ứng dụng)

-- Trigger function để tự động điền khu vực ưu tiên
CREATE OR REPLACE FUNCTION auto_fill_khu_vuc_uu_tien()
RETURNS TRIGGER AS $$
BEGIN
    -- Kiểm tra xem ma_truong_thpt có được nhập hay không
    IF NEW.ma_truong_thpt IS NOT NULL THEN
        -- Lấy khu vực xét tuyển từ bảng truong_thpt dựa trên ma_truong_thpt và ma_tinh_thanh_pho
        SELECT khu_vuc_xet_tuyen
        INTO NEW.khu_vuc_uu_tien
        FROM truong_thpt
        WHERE ma_truong = NEW.ma_truong_thpt
          AND ma_tinh_thanh_pho = NEW.truong_thpt_ma_tinh;

        -- Nếu không tìm thấy trường THPT phù hợp, có thể đặt khu vực ưu tiên thành NULL hoặc giá trị mặc định khác
        IF NEW.khu_vuc_uu_tien IS NULL THEN
            RAISE NOTICE 'Không tìm thấy thông tin trường THPT có mã % và mã tỉnh %.', NEW.ma_truong_thpt, NEW.truong_thpt_ma_tinh;
            -- Có thể đặt NEW.khu_vuc_uu_tien = NULL; hoặc một giá trị mặc định khác tùy theo yêu cầu
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger để kích hoạt hàm auto_fill_khu_vuc_uu_tien khi có bản ghi mới được thêm vào bảng thi_sinh
CREATE TRIGGER trg_auto_fill_khu_vuc
BEFORE INSERT ON thi_sinh
FOR EACH ROW
EXECUTE FUNCTION auto_fill_khu_vuc_uu_tien();

-- Trigger để kích hoạt hàm auto_fill_khu_vuc_uu_tien khi trường ma_truong_thpt hoặc truong_thpt_ma_tinh được cập nhật trong bảng thi_sinh
CREATE TRIGGER trg_update_khu_vuc
BEFORE UPDATE OF ma_truong_thpt, truong_thpt_ma_tinh ON thi_sinh
FOR EACH ROW
WHEN (OLD.ma_truong_thpt IS DISTINCT FROM NEW.ma_truong_thpt OR OLD.truong_thpt_ma_tinh IS DISTINCT FROM NEW.truong_thpt_ma_tinh)
EXECUTE FUNCTION auto_fill_khu_vuc_uu_tien();


-- Xóa nguyện vọng
CREATE OR REPLACE FUNCTION remove_nv()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE nguyen_vong_xet_tuyen 
    SET thu_tu_nguyen_vong = thu_tu_nguyen_vong - 1 
    WHERE cccd = OLD.cccd 
      AND thu_tu_nguyen_vong > OLD.thu_tu_nguyen_vong;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER nguyen_vong_remove 
BEFORE DELETE ON nguyen_vong_xet_tuyen
FOR EACH ROW
EXECUTE FUNCTION remove_nv();

-- Xử lý thêm hoặc chỉnh thứ tự nguyện vọng
CREATE OR REPLACE FUNCTION add_update_nv()
RETURNS TRIGGER AS $$
DECLARE exist BOOLEAN;
BEGIN
	
	--Kiểm tra xem nguyên vọng được thêm hay chỉnh sửa đã tồn tại hay chưa
	SELECT EXISTS (SELECT * FROM nguyen_vong_xet_tuyen WHERE NEW.ma_nganh = ma_nganh AND NEW.cccd = cccd) INTO exist;

	IF exist THEN
		 RAISE EXCEPTION 'Nguyện vọng bị trùng';
	END IF;
   
   --Đảm bảo xóa nguyện vọng cũ nếu update
    IF TG_OP = 'UPDATE' THEN
        DELETE FROM nguyen_vong_xet_tuyen
        WHERE cccd = OLD.cccd 
          AND thu_tu_nguyen_vong = OLD.thu_tu_nguyen_vong;
    END IF;

	--Hạ bậc của các nguyện vọng từ nó trở xuống
    UPDATE nguyen_vong_xet_tuyen
    SET thu_tu_nguyen_vong = thu_tu_nguyen_vong + 1
    WHERE cccd = NEW.cccd 
      AND thu_tu_nguyen_vong >= NEW.thu_tu_nguyen_vong;

	   INSERT INTO nguyen_vong_xet_tuyen (cccd, ma_nganh, thu_tu_nguyen_vong)
	   VALUES (NEW.cccd, NEW.ma_nganh, NEW.thu_tu_nguyen_vong);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER nguyen_vong_add
BEFORE INSERT OR UPDATE ON nguyen_vong_xet_tuyen
FOR EACH ROW
EXECUTE FUNCTION add_update_nv();

--Trigger đảm bảo khi xóa hồ sơ xét tuyển, tất cả nguyện vọng bị xóa theo
CREATE OR REPLACE FUNCTION xoa_ho_so_xt_TG()
RETURNS TRIGGER AS $$
	
BEGIN
	DELETE FROM nguyen_vong_xet_tuyen
	WHERE ma_ho_so_xet_tuyen = OLD.ma_ho_so_xet_tuyen;

	RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER xoa_ho_so
BEFORE DELETE ON ho_so_xet_tuyen
FOR EACH ROW
EXECUTE FUNCTION xoa_ho_so_xt_TG();


--Trigger đảm bảo thí sinh không bị trùng
CREATE OR REPLACE FUNCTION them_thi_sinh_TG()
RETURNS TRIGGER AS $$
DECLARE 
	exist BOOLEAN;
BEGIN
	SELECT EXISTS(
		SELECT 1 FROM thi_sinh WHERE cccd = NEW.cccd
	) INTO exist;

	IF exist THEN
		RAISE EXCEPTION 'Thí sinh với CCCD % đã tồn tại!', NEW.cccd;
	END IF;

	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER them_thi_sinh
BEFORE INSERT OR UPDATE ON thi_sinh
FOR EACH ROW
EXECUTE FUNCTION them_thi_sinh_TG();
