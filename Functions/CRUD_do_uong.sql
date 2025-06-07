-- Thêm đồ uống mới
create or replace function f_them_do_uong(
	p_do_uong_id int,
	p_ten_do_uong varchar(100),
	p_loai_do_uong varchar(50),
	p_gia_ban numeric(18, 2),
	p_trang_thai varchar(50),
	p_mo_ta text
) returns void as
$$
begin
	insert into do_uong
	values (p_do_uong_id, p_ten_do_uong, p_loai_do_uong, p_gia_ban,
			p_trang_thai, p_mo_ta
	);
end;
$$ language plpgsql;

-- Cập nhật đồ uống
create or replace function f_cap_nhat_do_uong(
	p_do_uong_id int,
	p_ten_do_uong varchar(100),
	p_loai_do_uong varchar(50),
	p_gia_ban numeric(18, 2),
	p_trang_thai varchar(50),
	p_mo_ta text
) returns void as
$$
begin
	update do_uong
	set ten_do_uong = p_ten_do_uong,
		loai_do_uong = p_loai_do_uong,
		gia_ban = p_gia_ban,
		trang_thai = p_trang_thai,
		mo_ta = p_mo_ta
	where do_uong_id = p_do_uong_id;
end;
$$ language plpgsql;

-- Lấy thông tin đồ uống theo ID
create or replace function f_lay_thong_tin_do_uong(p_do_uong_id int)
returns table (
	do_uong_id int,
	ten_do_uong varchar(100),
	loai_do_uong varchar(50),
	gia_ban numeric(18, 2),
	trang_thai varchar(50),
	mo_ta text
) as
$$
begin
	return query
	select * from do_uong du where du.do_uong_id = p_do_uong_id;
end;
$$ language plpgsql;

-- Lấy danh sách đồ uống
create or replace function f_lay_danh_sach_do_uong()
returns table (
	do_uong_id int,
	ten_do_uong varchar(100),
	loai_do_uong varchar(50),
	gia_ban numeric(18, 2),
	trang_thai varchar(50),
	mo_ta text
) as
$$
begin
	return query
	select * from do_uong;
end;
$$ language plpgsql;