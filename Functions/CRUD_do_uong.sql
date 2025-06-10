-- Thêm đồ uống mới
create or replace function f_them_do_uong(
    p_ten_do_uong varchar(100),
    p_loai_do_uong varchar(50),
    p_gia_ban numeric(18, 2),
    p_trang_thai varchar(50),
    p_mo_ta text
) returns void as
$$
declare
    v_do_uong_id int;
begin
    -- Kiểm tra tên đồ uống
    if p_ten_do_uong is null or trim(p_ten_do_uong) = '' then
        raise exception 'Vui lòng nhập Tên đồ uống.';
    end if;

    -- Kiểm tra loại đồ uống
    if p_loai_do_uong is null or trim(p_loai_do_uong) = '' then
        raise exception 'Vui lòng nhập Loại đồ uống.';
    end if;

    -- Kiểm tra giá bán
    if p_gia_ban is null or p_gia_ban < 0 then
        raise exception 'Giá bán không hợp lệ: Phải là số không âm.';
    end if;

    -- Kiểm tra trạng thái
    if p_trang_thai not in ('Đang bán', 'Tạm hết', 'Ngừng bán') then
        raise exception 'Trạng thái không hợp lệ: %. Chỉ chấp nhận ''Đang bán'', ''Tạm hết'' hoặc ''Ngừng bán''.', p_trang_thai;
    end if;

    -- Kiểm tra trùng lặp tên đồ uống
    if exists (select 1 from do_uong where ten_do_uong = trim(p_ten_do_uong)) then
        raise exception 'Tên món này đã tồn tại: %.', p_ten_do_uong;
    end if;

    -- Tạo do_uong_id
	-- select coalesce(max(do_uong_id), 0) + 1 into v_do_uong_id from do_uong;
    select nextval('do_uong_id_seq') into v_do_uong_id;

    -- Chèn dữ liệu vào bảng do_uong
    insert into do_uong
    values (v_do_uong_id, trim(p_ten_do_uong), trim(p_loai_do_uong),
			p_gia_ban, p_trang_thai, p_mo_ta);
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
declare
    v_do_uong_exists boolean;
begin
    -- Kiểm tra đồ uống có tồn tại
    select exists(select 1 from do_uong where do_uong_id = p_do_uong_id) into v_do_uong_exists;
    if not v_do_uong_exists then
        raise exception 'Đồ uống với mã % không tồn tại.', p_do_uong_id;
    end if;

    -- Kiểm tra tên đồ uống
    if p_ten_do_uong is null or trim(p_ten_do_uong) = '' then
        raise exception 'Vui lòng nhập Tên đồ uống.';
    end if;

    -- Kiểm tra loại đồ uống
    if p_loai_do_uong is null or trim(p_loai_do_uong) = '' then
        raise exception 'Vui lòng nhập Loại đồ uống.';
    end if;

    -- Kiểm tra giá bán
    if p_gia_ban is null or p_gia_ban < 0 then
        raise exception 'Giá bán không hợp lệ: Phải là số không âm.';
    end if;

    -- Kiểm tra trạng thái
    if p_trang_thai not in ('Đang bán', 'Tạm hết', 'Ngừng bán') then
        raise exception 'Trạng thái không hợp lệ: %. Chỉ chấp nhận ''Đang bán'', ''Tạm hết'' hoặc ''Ngừng bán''.', p_trang_thai;
    end if;

    -- Kiểm tra trùng lặp tên đồ uống (loại trừ chính đồ uống đang cập nhật)
    if exists (
        select 1 from do_uong
        where ten_do_uong = trim(p_ten_do_uong)
        and do_uong_id != p_do_uong_id
    ) then
        raise exception 'Tên đồ uống này đã tồn tại: %.', p_ten_do_uong;
    end if;

    -- Cập nhật thông tin đồ uống
    update do_uong
    set
        ten_do_uong = trim(p_ten_do_uong),
        loai_do_uong = trim(p_loai_do_uong),
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
    mo_ta text,
    cong_thuc text
) as
$$
begin
    -- Kiểm tra đồ uống có tồn tại
    if not exists (select 1 from do_uong where do_uong_id = p_do_uong_id) then
        raise exception 'Đồ uống với mã % không tồn tại.', p_do_uong_id;
    end if;

    return query
    select 
        du.do_uong_id,
        du.ten_do_uong,
        du.loai_do_uong,
        du.gia_ban,
        du.trang_thai,
        du.mo_ta,
        string_agg(concat(nl.ten_nguyen_lieu, ': ', ct.so_luong, ' ', nl.don_vi_tinh),', ') as cong_thuc
    from do_uong du
    left join cong_thuc ct on du.do_uong_id = ct.do_uong_id
    left join nguyen_lieu nl on ct.nguyen_lieu_id = nl.nguyen_lieu_id
    where du.do_uong_id = p_do_uong_id
    group by 
        du.do_uong_id,
        du.ten_do_uong,
        du.loai_do_uong,
        du.gia_ban,
        du.trang_thai,
        du.mo_ta;
end;
$$ language plpgsql;


-- Lấy danh sách đồ uống
create or replace function f_lay_danh_sach_do_uong(
	p_trang_thai varchar(50) default null
)
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
	-- Kiểm tra trạng thái
	if p_trang_thai is not null and p_trang_thai not in ('Đang bán', 'Tạm hết', 'Ngừng bán') then
		raise exception 'Trạng thái không hợp lệ: % Chỉ chấp nhận ''Đang bán'', ''Tạm hết'', hoặc ''Ngừng bán''.', p_trang_thai;
	end if;
	
	return query
	select *
	from do_uong du
	where
		case
			when p_trang_thai is null then true
			else du.trang_thai = p_trang_thai
		end
	order by du.do_uong_id;
end;
$$ language plpgsql;


-- Xoá đồ uống
create or replace function f_xoa_do_uong(
    p_do_uong_id int
) returns void as
$$
declare
    v_do_uong_exists boolean;
    v_has_cong_thuc boolean;
    v_has_active_order boolean;
begin
    -- Kiểm tra đồ uống có tồn tại
    select exists(select 1 from do_uong where do_uong_id = p_do_uong_id) into v_do_uong_exists;
    if not v_do_uong_exists then
        raise exception 'Đồ uống với mã % không tồn tại.', p_do_uong_id;
    end if;

    -- Kiểm tra xem đồ uống có trong công thức
    select exists(select 1 from cong_thuc where do_uong_id = p_do_uong_id) into v_has_cong_thuc;
    if v_has_cong_thuc then
        raise exception 'Không thể xóa đồ uống vì đã có trong công thức.';
    end if;

    -- Kiểm tra xem đồ uống có trong đơn hàng chưa hủy
    select exists(
        select 1
        from chi_tiet_don_hang_nuoc ctdh
        join don_hang dh on ctdh.don_hang_id = dh.don_hang_id
        left join (
            select don_hang_id, trang_thai
            from trang_thai
            where (don_hang_id, thoi_gian) in (
                select don_hang_id, max(thoi_gian)
                from trang_thai
                group by don_hang_id
            )
        ) tt on dh.don_hang_id = tt.don_hang_id
        where ctdh.do_uong_id = p_do_uong_id
        and (tt.trang_thai is null or tt.trang_thai != 'Hủy')
    ) into v_has_active_order;

    if v_has_active_order then
        raise exception 'Không thể xóa đồ uống vì đã có trong lịch sử giao dịch.';
    end if;

    -- Xóa đồ uống
    delete from do_uong where do_uong_id = p_do_uong_id;
end;
$$ language plpgsql;