-- CRUD_sach
select * from sach;

select f_them_sach(10, '7 Thói quen hiệu quả', 'NXB Tổng hợp', 2018, 'Kỹ năng', 40, 5, 150000, 'Tham khảo', 'Ngừng bán');

select f_cap_nhat_sach(9, '7 Thói quen hiệu quả', 'NXB Tổng hợp', 2018, 'Kỹ năng', 40, 5, 150000, 'Để bán', 'Đang bán');

select * from f_lay_thong_tin_sach(1);

select * from f_lay_danh_sach_sach();

select f_cap_nhat_trang_thai_sach(9, 'Ngừng bán');

-- CRUD_tac_gia
select * from tac_gia;

select f_them_tac_gia(12, 1, 'Lại Việt C');

select f_cap_nhat_tac_gia(12, 2, 'Lại Việt C');

select f_xoa_tac_gia(12);

select * from f_lay_tac_gia_theo_sach(1);

-- CRUD_do_uong
select * from do_uong;

select f_them_do_uong(3, 'Trà vải', 'Lạnh', 35000, 'Đang bán', 'Trà với tinh dầu vải và vải miếng');

select f_cap_nhat_do_uong(3, 'Trà đào cam sả', 'Lạnh', 40000, 'Đang bán', 'Trà đào với cam và sả');

select * from f_lay_thong_tin_do_uong(3);

select * from f_lay_danh_sach_do_uong();

-- CRUD_nguyen_lieu
select * from nguyen_lieu;

select f_them_nguyen_lieu(4, 'Chanh', 50, 'quả', 50);

select f_cap_nhat_nguyen_lieu(4, 'Chanh', 40, 'quả', 50);

select * from f_lay_thong_tin_nguyen_lieu(4);

select * from f_lay_danh_sach_nguyen_lieu();

-- CRUD_cong_thuc
select * from cong_thuc;

select f_them_nguyen_lieu_vao_cong_thuc(2, 3, 0.02);

select f_cap_nhat_cong_thuc(2, 3, 0.05);

select f_xoa_nguyen_lieu_cong_thuc(2, 3);

select * from f_xem_cong_thuc(1);

-- F-IM
select * from f_bao_cao_ton_kho();

select * from f_canh_bao_ton_kho_thap();

select f_dieu_chinh_ton_kho_sach(1, 30);

select f_dieu_chinh_ton_kho_nguyen_lieu(4, 100);

-- F-PO
select * from phieu_nhap;

select * from nhan_vien;

select f_tao_phieu_nhap_moi(3, 2, 2, 'Sách');

select f_them_chi_tiet_phieu_nhap_sach(3, 1, 1, 20000);

select f_xoa_chi_tiet_phieu_nhap_sach(3, 1);

select f_tao_phieu_nhap_moi(4, 2, 2, 'Nguyên liệu');

select f_them_chi_tiet_phieu_nhap_nguyen_lieu(4, 4, 1, 20000);

select f_xoa_chi_tiet_phieu_nhap_nguyen_lieu(4, 4);

select * from f_xem_chi_tiet_phieu_nhap(4);