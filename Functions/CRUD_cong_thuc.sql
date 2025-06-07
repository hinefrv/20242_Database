-- Thêm nguyên liệu vào công thức
create or replace function f_them_nguyen_lieu_vao_cong_thuc(
	p_do_uong_id int,
	p_nguyen_lieu_id int,
	p_so_luong numeric(10, 2)
) returns void as
$$
begin
	insert into cong_thuc
	values (p_do_uong_id, p_nguyen_lieu_id, p_so_luong);
end;
$$ language plpgsql;

-- Cập nhật số lượng nguyên liệu trong công thức
create or replace function f_cap_nhat_cong_thuc(
	p_do_uong_id int,
	p_nguyen_lieu_id int,
	p_so_luong numeric(10, 2)
) returns void as
$$
begin
	update cong_thuc
	set so_luong = p_so_luong
	where do_uong_id = p_do_uong_id
		and nguyen_lieu_id = p_nguyen_lieu_id;
end;
$$ language plpgsql;

-- Xoá nguyên liệu khỏi công thức
create or replace function f_xoa_nguyen_lieu_cong_thuc(
	p_do_uong_id int,
	p_nguyen_lieu_id int
) returns void as
$$
begin
	delete from cong_thuc
	where do_uong_id = p_do_uong_id
		and nguyen_lieu_id = p_nguyen_lieu_id;
end;
$$ language plpgsql;

-- Xem công thức đồ uống
create or replace function f_xem_cong_thuc(p_do_uong_id int)
returns table (
	nguyen_lieu_id int,
	ten_nguyen_lieu varchar(100),
	so_luong numeric(10, 2),
	don_vi_tinh varchar(20)
) as
$$
begin
	return query
	select nl.nguyen_lieu_id, nl.ten_nguyen_lieu,
			ct.so_luong, nl.don_vi_tinh
	from cong_thuc ct
	join nguyen_lieu nl using (nguyen_lieu_id)
	where ct.do_uong_id = p_do_uong_id;
end;
$$ language plpgsql;