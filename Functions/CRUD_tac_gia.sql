-- Thêm tác giả mới
create or replace function f_them_tac_gia(
	p_sach_id int,
	p_ten_tac_gia varchar(100)
) returns void as
$$
declare
	v_tac_gia_id int;
begin
	-- Kiểm tra sách tồn tại
    if not exists (select 1 from sach where sach_id = p_sach_id) then
        raise exception 'Sách với mã % không tồn tại.', p_sach_id;
    end if;

    -- Kiểm tra tên tác giả bắt buộc
    if p_ten_tac_gia is null or trim(p_ten_tac_gia) = '' then
        raise exception 'Vui lòng nhập Tên tác giả.';
    end if;

    -- Tạo tac_gia_id
	-- select coalesce(max(tac_gia_id), 0) + 1 into v_tac_gia_id from tac_gia;
    select nextval('tac_gia_id_seq') into v_tac_gia_id;

	-- Chèn dữ liệu
	insert into tac_gia (tac_gia_id, sach_id, ten_tac_gia)
	values (v_tac_gia_id, p_sach_id, trim(p_ten_tac_gia));
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
    -- Kiểm tra tác giả tồn tại
    if not exists (select 1 from tac_gia where tac_gia_id = p_tac_gia_id) then
        raise exception 'Tác giả với mã % không tồn tại.', p_tac_gia_id;
    end if;

    -- Kiểm tra sách tồn tại
    if not exists (select 1 from sach where sach_id = p_sach_id) then
        raise exception 'Sách với mã % không tồn tại.', p_sach_id;
    end if;

    -- Kiểm tra tên tác giả
    if p_ten_tac_gia is null or trim(p_ten_tac_gia) = '' then
        raise exception 'Vui lòng nhập Tên tác giả.';
    end if;

	-- Cập nhật thông tin
	update tac_gia
	set sach_id = p_sach_id, ten_tac_gia = trim(p_ten_tac_gia)
	where tac_gia_id = p_tac_gia_id;
end;
$$ language plpgsql;

-- Xoá tác giả
create or replace function f_xoa_tac_gia(p_tac_gia_id int)
returns void as
$$
begin
	-- Kiểm tra tác giả tồn tại
    if not exists (select 1 from tac_gia where tac_gia_id = p_tac_gia_id) then
        raise exception 'Tác giả với mã % không tồn tại.', p_tac_gia_id;
    end if;

	-- Xoá tác giả
	delete from tac_gia where tac_gia_id = p_tac_gia_id;
end;
$$ language plpgsql;

-- Lấy thông tin tác giả theo ID
create or replace function f_lay_thong_tin_tac_gia(p_tac_gia_id int)
returns table (
	tac_gia_id int,
	sach_id int,
	ten_tac_gia varchar(100),
	ten_sach varchar(255)
) as
$$
begin
    -- Kiểm tra tác giả tồn tại
    if not exists (select 1 from tac_gia where tac_gia_id = p_tac_gia_id) then
        raise exception 'Tác giả với mã % không tồn tại.', p_tac_gia_id;
    end if;

	return query
	select t.*, s.ten_sach
	from tac_gia t
	join sach s using (sach_id)
	where t.tac_gia_id = p_tac_gia_id;
end;
$$ language plpgsql;

-- Lấy danh sách tác giả theo sách
create or replace function f_lay_tac_gia_theo_sach(p_sach_id int)
returns table (
	tac_gia_id int,
	sach_id int,
	ten_tac_gia varchar(100),
	ten_sach varchar(255)
) as
$$
begin
	-- Kiểm tra sách tồn tại
    if not exists (select 1 from sach where sach_id = p_sach_id) then
        raise exception 'Sách với mã % không tồn tại.', p_sach_id;
    end if;

	return query
	select t.*, s.ten_sach
	from tac_gia t
	join sach s using (sach_id)
	where t.sach_id = p_sach_id;
end;
$$ language plpgsql;

