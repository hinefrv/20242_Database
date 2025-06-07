-- Thêm nguyên liệu mới
create or replace function f_them_nguyen_lieu(
	p_nguyen_lieu_id int,
	p_ten_nguyen_lieu varchar(100),
	p_so_luong int,
	p_don_vi_tinh varchar(20),
	p_nguong_canh_bao int
) returns void as
$$
begin
	insert into nguyen_lieu
	values (p_nguyen_lieu_id, p_ten_nguyen_lieu, p_so_luong,
			p_don_vi_tinh, p_nguong_canh_bao
	);
end;
$$ language plpgsql;

-- Cập nhật nguyên liệu
create or replace function f_cap_nhat_nguyen_lieu(
	p_nguyen_lieu_id int,
	p_ten_nguyen_lieu varchar(100),
	p_so_luong int,
	p_don_vi_tinh varchar(20),
	p_nguong_canh_bao int
) returns void as
$$
begin
	update nguyen_lieu
	set ten_nguyen_lieu = p_ten_nguyen_lieu,
		so_luong = p_so_luong,
		don_vi_tinh = p_don_vi_tinh,
		nguong_canh_bao = p_nguong_canh_bao
	where nguyen_lieu_id = p_nguyen_lieu_id;
end;
$$ language plpgsql;

-- Lấy thông tin nguyên liệu theo ID
create or replace function f_lay_thong_tin_nguyen_lieu(p_nguyen_lieu_id int)
returns table (
	nguyen_lieu_id int,
	ten_nguyen_lieu varchar(100),
	so_luong int,
	don_vi_tinh varchar(20),
	nguong_canh_bao int
) as
$$
begin
	return query
	select * from nguyen_lieu nl where nl.nguyen_lieu_id = p_nguyen_lieu_id;
end;
$$ language plpgsql;

-- Lấy danh sách nguyên liệu
create or replace function f_lay_danh_sach_nguyen_lieu()
returns table (
	nguyen_lieu_id int,
	ten_nguyen_lieu varchar(100),
	so_luong int,
	don_vi_tinh varchar(20),
	nguong_canh_bao int
) as
$$
begin
	return query
	select * from nguyen_lieu;
end;
$$ language plpgsql;