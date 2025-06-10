-- Tạo sequences cho id tự động
create sequence if not exists sach_id_seq start with 1 increment by 1;
create sequence if not exists tac_gia_id_seq start with 1 increment by 1;
create sequence if not exists do_uong_id_seq start with 1 increment by 1;
create sequence if not exists nguyen_lieu_id_seq start with 1 increment by 1;
create sequence if not exists phieu_nhap_id_seq start with 1 increment by 1;

-- Đồng bộ sequences nếu bảng đã có dữ liệu
select setval('sach_id_seq', (select max(sach_id) from sach));
select setval('tac_gia_id_seq', (select max(tac_gia_id) from tac_gia));
select setval('do_uong_id_seq', (select max(do_uong_id) from do_uong));
select setval('nguyen_lieu_id_seq', (select max(nguyen_lieu_id) from nguyen_lieu));
select setval('phieu_nhap_id_seq', (select max(phieu_nhap_id) from phieu_nhap));
