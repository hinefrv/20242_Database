-- Thêm sách mới
create or replace function f_them_sach(
	p_sach_id int,
	P_ten_sach varchar(255),
	p_nha_xuat_ban varchar(100),
	p_nam_xuat_ban int,
	p_the_loai varchar(100),
	p_so_luong int,
	p_nguong_toi_thieu int,
	p_gia_ban numeric(18, 2),
	p_phan_loai varchar(50),
	p_trang_thai varchar(50)
) returns void as
$$
begin
	insert into sach
	values (
		p_sach_id, p_ten_sach, p_nha_xuat_ban, p_nam_xuat_ban,
		p_the_loai, p_so_luong, p_nguong_toi_thieu, p_gia_ban,
		p_phan_loai, p_trang_thai
	);
end;
$$ language plpgsql;

-- Cập nhật thông tin sách
create or replace function f_cap_nhat_sach(
	p_sach_id int,
	p_ten_sach varchar(255),
	p_nha_xuat_ban varchar(100),
	p_nam_xuat_ban int,
	p_the_loai varchar(100),
	p_so_luong int,
	p_nguong_toi_thieu int,
	p_gia_ban numeric(18, 2),
	p_phan_loai varchar(50),
	p_trang_thai varchar(50)
) returns void as
$$
begin
	update sach
	set ten_sach = p_ten_sach,
		nha_xuat_ban = p_nha_xuat_ban,
		nam_xuat_ban = p_nam_xuat_ban,
		the_loai = p_the_loai,
		nguong_toi_thieu = p_nguong_toi_thieu,
		gia_ban = p_gia_ban,
		phan_loai = p_phan_loai,
		trang_thai = p_trang_thai
	where sach_id = p_sach_id;
end;
$$ language plpgsql;

-- Lấy thông tin sách theo ID
create or replace function f_lay_thong_tin_sach(p_sach_id int)
returns table (
	sach_id int,
	ten_sach varchar(255),
	nha_xuat_ban varchar(100),
	nam_xuat_ban int,
	the_loai varchar(100),
	so_luong int,
	nguong_toi_thieu int,
	gia_ban numeric(18, 2),
	phan_loai varchar(50),
	trang_thai varchar(50)
) as
$$
begin
	return query
	select * from sach s where s.sach_id = p_sach_id;
end;
$$ language plpgsql;

-- Lấy danh sách tất cả các sách
create or replace function f_lay_danh_sach_sach()
returns table (
	sach_id int,
	ten_sach varchar(255),
	nha_xuat_ban varchar(100),
	nam_xuat_ban int,
	the_loai varchar(100),
	so_luong int,
	nguong_toi_thieu int,
	gia_ban numeric(18, 2),
	phan_loai varchar(50),
	trang_thai varchar(50)
) as
$$
begin
	return query
	select * from sach;
end;
$$ language plpgsql;

-- Cập nhật trạng thái sách
create or replace function f_cap_nhat_trang_thai_sach(p_sach_id int, p_trang_thai varchar(50))
returns void as
$$
begin
	update sach
	set trang_thai = p_trang_thai
	where sach_id = p_sach_id;
end;
$$ language plpgsql;
