-- Database: postgres

-- DROP DATABASE IF EXISTS postgres;

CREATE DATABASE postgres
    WITH
    OWNER = azure_pg_admin
    ENCODING = 'UTF8'
    LC_COLLATE = 'en_US.utf8'
    LC_CTYPE = 'en_US.utf8'
    LOCALE_PROVIDER = 'libc'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;

COMMENT ON DATABASE postgres
    IS 'default administrative connection database';
  

-- Tạo bảng Trường THPT
CREATE TABLE truong_thpt (
    ma_truong INT PRIMARY KEY,
    ten_truong_thpt VARCHAR(100),
    ma_tinh_thanh_pho INT,
    tinh_thanh_pho VARCHAR(20),
    dia_chi VARCHAR(200),
    khu_vuc_xet_tuyen CHAR(3) CHECK (khu_vuc_xet_tuyen IN ('1', '2', '2NT', '3'))
);

-- Tạo bảng Thí sinh
CREATE TABLE thi_sinh (
    cccd CHAR(12) PRIMARY KEY,
    ho_ten VARCHAR(50) NOT NULL,
    gioi_tinh VARCHAR(10) CHECK (gioi_tinh IN ('Nam', 'Nữ')),
    ngay_sinh DATE,
    dan_toc VARCHAR(20),
    dia_chi_thuong_tru VARCHAR(200),
    dia_chi_lien_lac VARCHAR(200),
    truong_thpt_ma_tinh INT,
    ma_truong_thpt INT,
    email VARCHAR(50),
    so_dien_thoai CHAR(10),
    khu_vuc_uu_tien CHAR(3),
    doi_tuong_uu_tien INT CHECK (doi_tuong_uu_tien BETWEEN 0 AND 7),
    FOREIGN KEY (ma_truong_thpt) REFERENCES truong_thpt(ma_truong)
);

-- Tạo bảng Tài khoản thí sinh
CREATE TABLE tai_khoan_thi_sinh (
    cccd VARCHAR(12) PRIMARY KEY,
    mat_khau VARCHAR(50) NOT NULL,
    FOREIGN KEY (cccd) REFERENCES thi_sinh(cccd)
);

-- Tạo bảng Hồ sơ dự thi
CREATE TABLE ho_so_du_thi (
    ma_ho_so_du_thi CHAR(10) PRIMARY KEY,
    cccd VARCHAR(12) NOT NULL,
    dia_diem_du_thi VARCHAR(20),
    tinh_trang_thanh_toan CHAR CHECK (tinh_trang_thanh_toan IN ('chua_thanh_toan', 'da_thanh_toan')),
    le_phi_thi NUMERIC,
    thoi_gian_thanh_toan_le_phi_thi DATE,
    dot_thi INT CHECK (dot_thi IN (1, 2)),
    FOREIGN KEY (cccd) REFERENCES thi_sinh(cccd)
);

-- Tạo bảng Kết quả thi
CREATE TABLE ket_qua_thi (
    cccd VARCHAR(12),
    diem_thanh_phan_tieng_viet INT CHECK (diem_thanh_phan_tieng_viet <= 300),
    diem_thanh_phan_tieng_anh INT CHECK (diem_thanh_phan_tieng_anh <= 300),
    diem_thanh_phan_toan_hoc INT CHECK (diem_thanh_phan_toan_hoc <= 300),
    diem_thanh_phan_logic_phan_tich_so_lieu INT CHECK (diem_thanh_phan_logic_phan_tich_so_lieu <= 120),
    diem_thanh_phan_suy_luan_khoa_hoc INT CHECK (diem_thanh_phan_suy_luan_khoa_hoc <= 180),
    ket_qua_thi INT CHECK (ket_qua_thi <= 1200),-- tổng điểm 5 kỹ năng,
    dot_thi INT CHECK (dot_thi in (1,2)),
	primary key (cccd,dot_thi)
    FOREIGN KEY (cccd) REFERENCES thi_sinh(cccd)
);

-- Tạo bảng Ngành đào tạo đại học
CREATE TABLE nganh_dao_tao_dai_hoc (
    ma_nganh varCHAR(20) PRIMARY KEY,
    ten_nganh VARCHAR(50),
    ma_truong_khoa CHAR(3),
    ten_truong_khoa VARCHAR(100),
    chi_tieu_tuyen_sinh INT,
    diem_chuan_nam_truoc INT
);

-- Tạo bảng Hồ sơ xét tuyển
CREATE TABLE ho_so_xet_tuyen (
    ma_ho_so_xet_tuyen CHAR(10) PRIMARY KEY,
    cccd CHAR(12) NOT NULL,
    diem_thi INT,
    khu_vuc_uu_tien CHAR(3),
    doi_tuong_uu_tien INT,
    diem_xet_tuyen FLOAT,-- được tính toán từ điểm thi, điểm KVUT, điểm DTUT
    FOREIGN KEY (cccd) REFERENCES thi_sinh(cccd)
);

-- Tạo bảng Nguyện vọng xét tuyển
CREATE TABLE nguyen_vong_xet_tuyen (
    ma_ho_so_xet_tuyen CHAR(10),
    cccd CHAR(12),
    ma_nganh CHAR(20),
    thu_tu_nguyen_vong INT,
    trang_thai_cua_nguyen_vong VARCHAR(20) CHECK (trang_thai_cua_nguyen_vong IN ('Đang chờ', 'Bị loại', 'Đủ điều kiện', 'Chưa xét')),
    diem_xet_tuyen FLOAT,
    PRIMARY KEY (ma_ho_so_xet_tuyen, ma_nganh),
    FOREIGN KEY (ma_ho_so_xet_tuyen) REFERENCES ho_so_xet_tuyen(ma_ho_so_xet_tuyen),
    FOREIGN KEY (cccd) REFERENCES thi_sinh(cccd),
    FOREIGN KEY (ma_nganh) REFERENCES nganh_dao_tao_dai_hoc(ma_nganh)
);

-- Tạo bảng Danh sách đủ điều kiện trúng tuyển
CREATE TABLE danh_sach_du_dieu_kien_trung_tuyen (
    ma_truong CHAR(3),
    ma_nganh CHAR(20),
    cccd CHAR(12),
    diem_xet_tuyen FLOAT,
    PRIMARY KEY (ma_nganh, cccd),
    FOREIGN KEY (ma_nganh) REFERENCES nganh_dao_tao_dai_hoc(ma_nganh),
    FOREIGN KEY (cccd) REFERENCES thi_sinh(cccd)
);


-- Tạo bảng Tài khoản quản lý xét tuyển
CREATE TABLE tai_khoan_quan_ly_xet_tuyen (
    ten_dang_nhap CHAR(20) PRIMARY KEY,
    mat_khau CHAR(50) NOT NULL
);

-- Tạo bảng Kỹ năng của thí sinh
CREATE TABLE ky_nang_cua_thi_sinh (
    cccd CHAR(12) PRIMARY KEY,
    danh_gia_ky_nang_tieng_viet INT CHECK (danh_gia_ky_nang_tieng_viet IN (0, 1, 2)),
    danh_gia_ky_nang_tieng_anh INT CHECK (danh_gia_ky_nang_tieng_anh IN (0, 1, 2)),
    danh_gia_ky_nang_toan_hoc INT CHECK (danh_gia_ky_nang_toan_hoc IN (0, 1, 2)),
    danh_gia_ky_nang_logic_phan_tich_so_lieu INT CHECK (danh_gia_ky_nang_logic_phan_tich_so_lieu IN (0, 1, 2)),
    danh_gia_ky_nang_suy_luan_khoa_hoc INT CHECK (danh_gia_ky_nang_suy_luan_khoa_hoc IN (0, 1, 2)),
    diem_thi_cao_nhat INT,
    FOREIGN KEY (cccd) REFERENCES ket_qua_thi(cccd)
    --TRIGGER cập nhật skill khi CRUD kết quả thi của thí sinh
);

-- Tạo bảng Ngành học - kỹ năng
CREATE TABLE nganh_hoc_ky_nang (
    ma_nganh CHAR(20) PRIMARY KEY,
    ten_nganh VARCHAR(50),
    ky_nang_tieng_viet INT CHECK (ky_nang_tieng_viet IN (0, 1, 2)),
    ky_nang_tieng_anh INT CHECK (ky_nang_tieng_anh IN (0, 1, 2)),
    ky_nang_toan_hoc INT CHECK (ky_nang_toan_hoc IN (0, 1, 2)),
    ky_nang_logic_phan_tich_so_lieu INT CHECK (ky_nang_logic_phan_tich_so_lieu IN (0, 1, 2)),
    ky_nang_suy_luan_khoa_hoc INT CHECK (ky_nang_suy_luan_khoa_hoc IN (0, 1, 2)),
    diem_chuan_nam_ngoai INT,
    FOREIGN KEY (ma_nganh) REFERENCES nganh_dao_tao_dai_hoc(ma_nganh)
);

-- Tạo bảng Các khuyến nghị ngành học
CREATE TABLE cac_khuyen_nghi_nganh_hoc (
    cccd CHAR(12),
    ma_nganh CHAR(20),
    ten_nganh VARCHAR(50),
    thu_tu_khuyen_nghi INT,
    PRIMARY KEY (cccd, ma_nganh),
    FOREIGN KEY (cccd) REFERENCES ky_nang_cua_thi_sinh(cccd),
    FOREIGN KEY (ma_nganh) REFERENCES nganh_hoc_ky_nang(ma_nganh)
);

-- Tạo bảng Bài đăng
CREATE TABLE bai_dang (
    ma_bai_dang CHAR(10) PRIMARY KEY,
    tieu_de VARCHAR(100),
    noi_dung TEXT,
    ngay_dang DATE,
    tag CHAR(20)
);

-- Tạo bảng Bình luận, phản hồi
CREATE TABLE binh_luan_phan_hoi (
    ma_bai_dang CHAR(10) PRIMARY KEY,
    noi_dung_binh_luan text,
    ngay_dang DATE,
    FOREIGN KEY (ma_bai_dang) REFERENCES bai_dang(ma_bai_dang)
);

-- Tạo bảng Câu hỏi thường gặp
CREATE TABLE cau_hoi_thuong_gap (
    ma_cau_hoi_thuong_gap CHAR(10) PRIMARY KEY,
    noi_dung_cau_hoi VARCHAR(200),
    noi_dung_tra_loi VARCHAR(500)
);

-- Tạo bảng Tài khoản tư vấn tuyển sinh
CREATE TABLE tai_khoan_tu_van_tuyen_sinh (
    ten_dang_nhap CHAR(20) PRIMARY KEY,
    mat_khau CHAR(50) NOT NULL
);

--Trigger cho bảng ky_nang_cua_thi_sinh
--Trigger tính tổng điểm kết quả thi
--Trigger tính điểm xét tuyển
--Trigger cập nhật điểm xét tuyển cho nguyện vọng
--Trigger tạo mã hồ sơ dự thi tự động
--Trigger tạo mã hồ sơ xét tuyển tự động
