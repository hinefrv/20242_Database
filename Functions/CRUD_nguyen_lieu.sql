-- Thêm nguyên liệu mới
create or replace function f_them_nguyen_lieu(
    p_ten_nguyen_lieu varchar(100),
    p_so_luong int,
    p_don_vi_tinh varchar(20),
    p_nguong_canh_bao int
) returns void as
$$
declare
    v_nguyen_lieu_id int;
begin
    -- Kiểm tra tên nguyên liệu
    if p_ten_nguyen_lieu is null or trim(p_ten_nguyen_lieu) = '' then
        raise exception 'Vui lòng nhập Tên nguyên liệu.';
    end if;

    -- Kiểm tra đơn vị tính
    if p_don_vi_tinh is null or trim(p_don_vi_tinh) = '' then
        raise exception 'Vui lòng nhập Đơn vị tính.';
    end if;

    -- Kiểm tra số lượng không âm
    if p_so_luong < 0 then
        raise exception 'Số lượng không hợp lệ: Phải là số không âm.';
    end if;

    -- Kiểm tra ngưỡng cảnh báo không âm
    if p_nguong_canh_bao < 0 then
        raise exception 'Ngưỡng cảnh báo không hợp lệ: Phải là số không âm.';
    end if;

    -- Kiểm tra trùng lặp tên nguyên liệu
    if exists (select 1 from nguyen_lieu where ten_nguyen_lieu = trim(p_ten_nguyen_lieu)) then
        raise exception 'Tên nguyên liệu này đã tồn tại: %.', p_ten_nguyen_lieu;
    end if;

    -- Tạo nguyen_lieu_id
	-- select coalesce(max(nguyen_lieu_id), 0) + 1 into v_nguyen_lieu_id from nguyen_lieu;
    select nextval('nguyen_lieu_id_seq') into v_nguyen_lieu_id;

    -- Chèn dữ liệu vào bảng nguyen_lieu
    insert into nguyen_lieu
    values (v_nguyen_lieu_id, trim(p_ten_nguyen_lieu), p_so_luong,
			trim(p_don_vi_tinh), p_nguong_canh_bao);
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
	-- Kiểm tra nguyên liệu có tồn tại
    if not exists (select 1 from nguyen_lieu where nguyen_lieu_id = p_nguyen_lieu_id) then
        raise exception 'Nguyên liệu với mã % không tồn tại.', p_nguyen_lieu_id;
    end if;

    -- Kiểm tra tên nguyên liệu
    if p_ten_nguyen_lieu is null or trim(p_ten_nguyen_lieu) = '' then
        raise exception 'Vui lòng nhập Tên nguyên liệu.';
    end if;

    -- Kiểm tra đơn vị tính
    if p_don_vi_tinh is null or trim(p_don_vi_tinh) = '' then
        raise exception 'Vui lòng nhập Đơn vị tính.';
    end if;

    -- Kiểm tra số lượng không âm
    if p_so_luong < 0 then
        raise exception 'Số lượng không hợp lệ: Phải là số không âm.';
    end if;

    -- Kiểm tra ngưỡng cảnh báo không âm
    if p_nguong_canh_bao < 0 then
        raise exception 'Ngưỡng cảnh báo không hợp lệ: Phải là số không âm.';
    end if;

    -- Kiểm tra trùng lặp tên nguyên liệu (loại trừ chính nguyên liệu đang cập nhật)
    if exists (
        select 1 from nguyen_lieu
        where ten_nguyen_lieu = trim(p_ten_nguyen_lieu)
        and nguyen_lieu_id != p_nguyen_lieu_id
    ) then
        raise exception 'Tên nguyên liệu này đã tồn tại: %.', p_ten_nguyen_lieu;
    end if;

	-- Cập nhật thông tin nguyên liệu
	update nguyen_lieu
	set ten_nguyen_lieu = trim(p_ten_nguyen_lieu),
		so_luong = p_so_luong,
		don_vi_tinh = trim(p_don_vi_tinh),
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
	-- Kiểm tra nguyên liệu có tồn tại
    if not exists (select 1 from nguyen_lieu where nguyen_lieu_id = p_nguyen_lieu_id) then
        raise exception 'Nguyên liệu với mã % không tồn tại.', p_nguyen_lieu_id;
    end if;
	
	return query
	select * 
	from nguyen_lieu nl where nl.nguyen_lieu_id = p_nguyen_lieu_id;
end;
$$ language plpgsql;

-- Lấy danh sách nguyên liệu
create or replace function f_lay_danh_sach_nguyen_lieu(
	p_trang_thai varchar(50) default null -- 'Cảnh báo' để dưới ngưỡng, 'Đủ dùng' để không dưới ngưỡng, null lấy tất cả
)
returns table (
	nguyen_lieu_id int,
	ten_nguyen_lieu varchar(100),
	so_luong int,
	don_vi_tinh varchar(20),
	nguong_canh_bao int
) as
$$
begin
	-- Kiểm tra trạng thái
	if p_trang_thai is not null and p_trang_thai not in ('Cảnh báo', 'Đủ dùng') then
		raise exception 'Trạng thái không hợp lê: % Chỉ chấp nhận ''Cảnh báo'' hoặc ''Đủ dùng'' hoặc null.', p_trang_thai;
	end if;

	return query
	select *
	from nguyen_lieu nl
	where
		case
			when p_trang_thai = 'Cảnh báo' then nl.so_luong < nl.nguong_canh_bao
			when p_trang_thai = 'Đủ dùng' then nl.so_luong >= nl.nguong_canh_bao
			else true -- Nếu p_trang_thai là null thì trả về tất cả bản ghi;
		end
	order by nl.nguyen_lieu_id;
end;
$$ language plpgsql;


-- Xoá nguyên liệu
create or replace function f_xoa_nguyen_lieu(
    p_nguyen_lieu_id int
) returns void as
$$
declare
    v_nguyen_lieu_exists boolean;
    v_has_cong_thuc boolean;
begin
    -- Kiểm tra nguyên liệu có tồn tại
    select exists(select 1 from nguyen_lieu where nguyen_lieu_id = p_nguyen_lieu_id) into v_nguyen_lieu_exists;
    if not v_nguyen_lieu_exists then
        raise exception 'Nguyên liệu với mã % không tồn tại.', p_nguyen_lieu_id;
    end if;

    -- Kiểm tra xem nguyên liệu có trong công thức
    select exists(select 1 from cong_thuc where nguyen_lieu_id = p_nguyen_lieu_id) into v_has_cong_thuc;
    if v_has_cong_thuc then
        raise exception 'Không thể xóa nguyên liệu này vì đang được sử dụng trong công thức pha chế.';
    end if;

    -- Xóa nguyên liệu
    delete from nguyen_lieu where nguyen_lieu_id = p_nguyen_lieu_id;

end;
$$ language plpgsql;