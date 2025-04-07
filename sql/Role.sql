

-- Tạo các vai trò tương ứng với nhóm người dùng
CREATE ROLE role_thi_sinh;
CREATE ROLE role_can_bo_ts;


-- Cấp quyền USAGE trên schema cho các role khác
GRANT USAGE ON SCHEMA public TO role_thi_sinh;
GRANT USAGE ON SCHEMA public TO role_can_bo_ts;

-- === Quyền cho Cán bộ Tuyển sinh (role_can_bo_ts) ===
-- Chỉ cấp quyền SELECT trên các bảng cần thiết
GRANT SELECT ON TABLE nganh_dao_tao_dai_hoc TO role_can_bo_ts;
GRANT SELECT ON TABLE danh_sach_du_dieu_kien_trung_tuyen TO role_can_bo_ts;
-- Nếu cần xem thông tin thí sinh trúng tuyển, cần cấp thêm quyền SELECT trên thi_sinh
GRANT SELECT ON TABLE thi_sinh TO role_can_bo_ts; -- Cân nhắc kỹ nếu cần ẩn thông tin nhạy cảm

-- === Quyền cho Thí sinh (role_thi_sinh) ===

-- 1. Cấp quyền cơ bản trên các bảng mà thí sinh được phép CRUD
GRANT SELECT, INSERT, UPDATE(ho_ten, gioi_tinh,ngay_sinh,dan_toc, dia_chi_thuong_tru, dia_chi_lien_lac, truong_thpt_ma_tinh, ma_truong_thpt, email, so_dien_thoai) ON TABLE thi_sinh TO role_thi_sinh;
-- thí sinh có quyền CRU các cột, trừ cột CCCD, cột khu vực ưu tiên (hệ thống tự xđ), cột đtut (cần duyệt, cập nhật bới admin)
GRANT SELECT, UPDATE(mat_khau) ON TABLE tai_khoan_thi_sinh TO role_thi_sinh; -- Chỉ cho update mật khẩu
GRANT SELECT, INSERT, UPDATE(dia_diem_du_thi)  ON TABLE ho_so_du_thi TO role_thi_sinh; -- chỉ được CRU cột dia_diem;
GRANT SELECT ON TABLE ket_qua_thi TO role_thi_sinh; --  chỉ xem -> SELECT
GRANT SELECT ON TABLE ho_so_xet_tuyen TO role_thi_sinh;
GRANT SELECT, INSERT, UPDATE(ma_nganh, thu_tu_nguyen_vong), DELETE ON TABLE nguyen_vong_xet_tuyen TO role_thi_sinh;
GRANT SELECT ON TABLE ky_nang_cua_thi_sinh TO role_thi_sinh; -- Thường chỉ SELECT, do trigger cập nhật? Nếu chỉ xem -> SELECT
GRANT SELECT ON TABLE cac_khuyen_nghi_nganh_hoc TO role_thi_sinh; -- Thường chỉ SELECT, do hệ thống tạo? Nếu chỉ xem -> SELECT

-- 2. Cấp quyền SELECT trên các bảng tham chiếu
GRANT SELECT ON TABLE nganh_dao_tao_dai_hoc TO role_thi_sinh;
GRANT SELECT ON TABLE truong_thpt TO role_thi_sinh;
GRANT SELECT ON TABLE danh_sach_du_dieu_kien_trung_tuyen TO role_thi_sinh; -- Để xem kết quả của bản thân

-- 3. Kích hoạt Row-Level Security (RLS) cho các bảng cần giới hạn theo CCCD
ALTER TABLE thi_sinh ENABLE ROW LEVEL SECURITY;
ALTER TABLE tai_khoan_thi_sinh ENABLE ROW LEVEL SECURITY;
ALTER TABLE ho_so_du_thi ENABLE ROW LEVEL SECURITY;
ALTER TABLE ket_qua_thi ENABLE ROW LEVEL SECURITY;
ALTER TABLE ho_so_xet_tuyen ENABLE ROW LEVEL SECURITY;
ALTER TABLE nguyen_vong_xet_tuyen ENABLE ROW LEVEL SECURITY;
ALTER TABLE ky_nang_cua_thi_sinh ENABLE ROW LEVEL SECURITY;
ALTER TABLE cac_khuyen_nghi_nganh_hoc ENABLE ROW LEVEL SECURITY;
ALTER TABLE danh_sach_du_dieu_kien_trung_tuyen ENABLE ROW LEVEL SECURITY; -- Chỉ cho xem dòng của mình

-- 4. Tạo Chính sách RLS (RLS Policies)
-- Chính sách này sử dụng một biến session tùy chỉnh 'app.current_cccd'
-- Biến này SẼ ĐƯỢC SET bởi ứng dụng sau khi thí sinh đăng nhập thành công.

-- Hàm helper để lấy cccd hiện tại (tránh lỗi nếu biến chưa được set)
CREATE OR REPLACE FUNCTION get_current_cccd() RETURNS char(12) AS $$
BEGIN
  RETURN current_setting('app.current_cccd', true); -- true nghĩa là trả về NULL nếu biến không tồn tại, không báo lỗi
EXCEPTION
  WHEN UNDEFINED_OBJECT THEN
    RETURN NULL;
END;
$$ LANGUAGE plpgsql STABLE;

-- Tạo chính sách chung cho phép thao tác nếu CCCD khớp
CREATE POLICY thi_sinh_policy ON thi_sinh
    FOR ALL -- Áp dụng cho SELECT, INSERT, UPDATE, DELETE
    TO role_thi_sinh -- Chỉ áp dụng cho role thí sinh
    USING (cccd = get_current_cccd()) -- Điều kiện để xem/sửa/xóa
    WITH CHECK (cccd = get_current_cccd()); -- Điều kiện để thêm/sửa (đảm bảo họ không chèn/đổi CCCD thành của người khác)

CREATE POLICY tai_khoan_thi_sinh_policy ON tai_khoan_thi_sinh
    FOR ALL
    TO role_thi_sinh
    USING (cccd = get_current_cccd())
    WITH CHECK (cccd = get_current_cccd()); -- Quan trọng: đảm bảo chỉ update pass của mình

CREATE POLICY ho_so_du_thi_policy ON ho_so_du_thi
    FOR ALL
    TO role_thi_sinh
    USING (cccd = get_current_cccd())
    WITH CHECK (cccd = get_current_cccd());

CREATE POLICY ket_qua_thi_policy ON ket_qua_thi
    FOR ALL -- Xem lại quyền nếu TS không được sửa kết quả thi
    TO role_thi_sinh
    USING (cccd = get_current_cccd())
    WITH CHECK (cccd = get_current_cccd());

CREATE POLICY ho_so_xet_tuyen_policy ON ho_so_xet_tuyen
    FOR ALL
    TO role_thi_sinh
    USING (cccd = get_current_cccd())
    WITH CHECK (cccd = get_current_cccd());

CREATE POLICY nguyen_vong_xet_tuyen_policy ON nguyen_vong_xet_tuyen
    FOR ALL
    TO role_thi_sinh
    USING (cccd = get_current_cccd())
    WITH CHECK (cccd = get_current_cccd());

CREATE POLICY ky_nang_cua_thi_sinh_policy ON ky_nang_cua_thi_sinh
    FOR ALL -- Xem lại quyền nếu TS không được sửa/thêm
    TO role_thi_sinh
    USING (cccd = get_current_cccd())
    WITH CHECK (cccd = get_current_cccd());

CREATE POLICY cac_khuyen_nghi_nganh_hoc_policy ON cac_khuyen_nghi_nganh_hoc
    FOR ALL -- Xem lại quyền nếu TS không được sửa/thêm
    TO role_thi_sinh
    USING (cccd = get_current_cccd())
    WITH CHECK (cccd = get_current_cccd());

CREATE POLICY ds_trung_tuyen_policy ON danh_sach_du_dieu_kien_trung_tuyen
    FOR SELECT -- Thí sinh chỉ được xem dòng của mình
    TO role_thi_sinh
    USING (cccd = get_current_cccd());



-- Xóa user nếu tồn tại
DROP USER IF EXISTS app_user_thi_sinh;
DROP USER IF EXISTS app_user_can_bo;

-- Tạo user cho ứng dụng khi thí sinh tương tác
CREATE USER app_user_thi_sinh WITH PASSWORD 'secure_password_for_app_ts';
GRANT role_thi_sinh TO app_user_thi_sinh;

-- Tạo user cho ứng dụng khi cán bộ tuyển sinh tương tác
CREATE USER app_user_can_bo WITH PASSWORD 'secure_password_for_app_cb';
GRANT role_can_bo_ts TO app_user_can_bo;



-- Xóa role nếu đã tồn tại (chỉ dùng khi test, cẩn thận trên production)
DROP ROLE IF EXISTS db_admin;

-- Tạo role quản trị viên mới
CREATE ROLE role_quan_tri_vien WITH
  LOGIN             -- Cho phép role này đăng nhập trực tiếp
  PASSWORD 'cnnb2023Aa@'; -- **QUAN TRỌNG: Thay bằng mật khẩu cực kỳ mạnh và an toàn**

 -- Ghi chú: Quản trị viên toàn cục (như user 'postgres') thường đã có sẵn.
-- role_quan_tri_vien ở đây có thể là một vai trò quản trị cấp thấp hơn hoặc một user riêng.
-- Nếu muốn QTV có toàn quyền, có thể cấp quyền SUPERUSER hoặc các quyền cụ thể.
-- Ví dụ cấp quyền đầy đủ trên schema public (thay 'public' nếu dùng schema khác)
ALTER ROLE role_quan_tri_vien CREATEDB CREATEROLE; -- Ví dụ các quyền admin cấp cao
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO role_quan_tri_vien WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO role_quan_tri_vien WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO role_quan_tri_vien WITH GRANT OPTION;
GRANT USAGE, CREATE ON SCHEMA public TO role_quan_tri_vien WITH GRANT OPTION;

-- Đảm bảo role QTV có quyền trên các bảng mới tạo sau này
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO role_quan_tri_vien;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON SEQUENCES TO role_quan_tri_vien;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON FUNCTIONS TO role_quan_tri_vien;
ALTER ROLE role_quan_tri_vien BYPASSRLS; -- Cho phép bỏ qua mọi chính sách RLS

CREATE USER admin_user with password 'cnnb2023Aa@';
GRANT role_quan_tri_vien TO admin_user;

