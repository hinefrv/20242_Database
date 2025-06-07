-- Thêm tác giả mới
create or replace function f_them_tac_gia(
	p_tac_gia_id int,
	p_sach_id int,
	p_ten_tac_gia varchar(100)
) returns void as
$$
begin
	insert into tac_gia (tac_gia_id, sach_id, ten_tac_gia)
	values (p_tac_gia_id, p_sach_id, p_ten_tac_gia);
end;
$$ language plpgsql;

-- Cập nhật tác giả
create or replace function f_cap_nhat_tac_gia(
	p_tac_gia_id int,
	p_sach_id int,
	p_ten_tac_gia varchar(100)
) returns void as
$$
begin
	update tac_gia
	set sach_id = p_sach_id, ten_tac_gia = p_ten_tac_gia
	where tac_gia_id = p_tac_gia_id;
end;
$$ language plpgsql;

-- Xoá tác giả
create or replace function f_xoa_tac_gia(p_tac_gia_id int)
returns void as
$$
begin
	delete from tac_gia where tac_gia_id = p_tac_gia_id;
end;
$$ language plpgsql;

-- Lấy thông tin tác giả theo ID
create or replace function f_lay_thong_tin_tac_gia(p_tac_gia_id int)
returns table (
	tac_gia_id int,
	sach_id int,
	ten_tac_gia varchar(100)
) as
$$
begin
	return query
	select * from tac_gia t where t.tac_gia_id = p_tac_gia_id;
end;
$$ language plpgsql;

-- Lấy danh sách tác giả theo sách
create or replace function f_lay_tac_gia_theo_sach(p_sach_id int)
returns table (
	tac_gia_id int,
	sach_id int,
	ten_tac_gia varchar(100)
) as
$$
begin
	return query
	select * from tac_gia t where t.sach_id = p_sach_id;
end;
$$ language plpgsql;
