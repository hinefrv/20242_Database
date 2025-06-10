-- Thêm sách mới
create or replace function f_them_sach(
	p_ten_sach varchar(255),
	p_ten_tac_gia varchar(100),
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
declare
	v_sach_id int;
begin
	-- Kiểm tra tên sách
	if p_ten_sach is null or trim(p_ten_sach) = '' then
		raise exception 'Vui lòng nhập Tên sách.';
	end if;

	-- Kiểm tra phân loại
	if p_phan_loai not in ('Để bán', 'Tham khảo') then
        raise exception 'Phân loại không hợp lệ: % Chỉ chấp nhận ''Để bán'' hoặc ''Tham khảo''.', p_phan_loai;
    end if;

	-- Kiểm tra giá bán
	if p_phan_loai = 'Để bán' then
		if p_gia_ban is null or gia_ban < 0 then
			raise exception 'Giá bán không hợp lệ: Phải là số không âm.';
		end if;
	else -- Tham khảo
		if p_gia_ban is not null and p_gia_ban < 0 then
			raise exception 'Giá bán không hợp lệ: Phải là số không âm hoặc để trống cho sách ''Tham khảo''.';
		end if;
	end if;

	-- Kiểm tra trạng thái
	if p_trang_thai not in ('Đang bán', 'Ngừng bán') then
        raise exception 'Trạng thái không hợp lệ: % Chỉ chấp nhận ''Đang bán'' hoặc ''Ngừng bán''.', p_trang_thai;
    end if;

	-- Kiểm tra số lượng và ngưỡng tối thiểu
	if p_so_luong < 0 then
		raise exception 'Số lượng không hợp lệ: Phải là số không âm.';
	end if;
	if p_nguong_toi_thieu < 0 then
		raise exception 'Ngưỡng tối thiểu không hợp lệ: Phải là số không âm.';
	end if;

	-- Tạo id tự động
	-- select coalesce(max(sach_id), 0) + 1 into v_sach_id from sach;
	select nextval('sach_id_seq') into v_sach_id;
		
	-- Chèn dữ liệu vào bảng
	insert into sach
	values (v_sach_id, trim(p_ten_sach), p_nha_xuat_ban, trim(p_nam_xuat_ban),
			trim(p_the_loai), p_so_luong, p_nguong_toi_thieu,
			case when p_phan_loai = 'Tham khảo' and p_gia_ban is null then null
			else p_gia_ban end,
			p_phan_loai, p_trang_thai);

	-- Chèn thông tin tác giả (nếu có)
	if p_ten_tac_gia is not null and trim(p_ten_tac_gia) != '' then
		insert into tac_gia
		values (nextval('tac_gia_id_seq'), v_sach_id, trim(p_ten_tac_gia)
		);
	else
		raise exception 'Vui lòng nhập tên tác giả';
	end if;
end;
$$ language plpgsql;

-- Cập nhật thông tin sách
create or replace function f_cap_nhat_sach(
	p_sach_id int,
	p_ten_sach varchar(255),
	p_ten_tac_gia varchar(100),
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
declare
	v_sach_exists boolean;
begin
	-- Kiểm tra sách có tồn tại
    select exists(select 1 from sach where sach_id = p_sach_id) into v_sach_exists;
    if not v_sach_exists then
        raise exception 'Sách với mã % không tồn tại.', p_sach_id;
    end if;

    -- Kiểm tra tên sách
    if p_ten_sach is null or trim(p_ten_sach) = '' then
        raise exception 'Vui lòng nhập tên sách.';
    end if;

    -- Kiểm tra phân loại
    if p_phan_loai not in ('Để bán', 'Tham khảo') then
        raise exception 'Phân loại không hợp lệ: %. Chỉ chấp nhận ''Để bán'' hoặc ''Tham khảo''.', p_phan_loai;
    end if;

    -- Kiểm tra giá bán
    if p_phan_loai = 'Để bán' then
        if p_gia_ban is null or p_gia_ban < 0 then
            raise exception 'Giá bán không hợp lệ: Phải là số không âm.';
        end if;
    else -- Tham khảo
        if p_gia_ban is not null and p_gia_ban < 0 then
            raise exception 'Giá bán không hợp lệ: Phải là số không âm hoặc để trống cho sách ''Tham khảo''.';
        end if;
    end if;

    -- Kiểm tra trạng thái
    if p_trang_thai not in ('Đang bán', 'Ngừng bán') then
        raise exception 'Trạng thái không hợp lệ: %. Chỉ chấp nhận ''Đang bán'' hoặc ''Ngừng bán''.', p_trang_thai;
    end if;

    -- Kiểm tra số lượng và ngưỡng tối thiểu
    if p_so_luong < 0 then
        raise exception 'Số lượng không hợp lệ: Phải là số không âm.';
    end if;
    if p_nguong_toi_thieu < 0 then
        raise exception 'Ngưỡng tối thiểu không hợp lệ: Phải là số không âm.';
    end if;

    -- Kiểm tra tên tác giả
    if p_ten_tac_gia is null or trim(p_ten_tac_gia) = '' then
        raise exception 'Vui lòng nhập Tên tác giả.';
    end if;
	
	update sach
	set ten_sach = trim(p_ten_sach),
		nha_xuat_ban = p_nha_xuat_ban,
		nam_xuat_ban = p_nam_xuat_ban,
		the_loai = p_the_loai,
		nguong_toi_thieu = p_nguong_toi_thieu,
		gia_ban = case when p_phan_loai = 'Tham khảo' 
					and p_gia_ban is null then null
					else p_gia_ban end,
		phan_loai = p_phan_loai,
		trang_thai = p_trang_thai
	where sach_id = p_sach_id;

	-- Cập nhật hoặc thêm tác giả
	if exists (select 1 from tac_gia where sach_id = p_sach_id) then
        update tac_gia
        set ten_tac_gia = trim(p_ten_tac_gia)
        where sach_id = p_sach_id;
    else
        insert into tac_gia (tac_gia_id, sach_id, ten_tac_gia)
        values (
            (select coalesce(max(tac_gia_id), 0) + 1 from tac_gia),
            p_sach_id, trim(p_ten_tac_gia)
        );
    end if;
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
    trang_thai varchar(50),
    ten_tac_gia text
) as
$$
begin
    -- Kiểm tra sách có tồn tại
    if not exists (select 1 from sach where sach_id = p_sach_id) then
        raise exception 'Sách với mã % không tồn tại.', p_sach_id;
    end if;

    return query
    select 
        s.sach_id,
        s.ten_sach,
        s.nha_xuat_ban,
        s.nam_xuat_ban,
        s.the_loai,
        s.so_luong,
        s.nguong_toi_thieu,
        s.gia_ban,
        s.phan_loai,
        s.trang_thai,
        s.mo_ta,
        string_agg(tg.ten_tac_gia, ', ') as ten_tac_gia
    from sach s
    left join tac_gia tg on s.sach_id = tg.sach_id
    where s.sach_id = p_sach_id
    group by 
        s.sach_id,
        s.ten_sach,
        s.nha_xuat_ban,
        s.nam_xuat_ban,
        s.the_loai,
        s.so_luong,
        s.nguong_toi_thieu,
        s.gia_ban,
        s.phan_loai,
        s.trang_thai,
        s.mo_ta;
end;
$$ language plpgsql;

-- Lấy danh sách tất cả các sách
create or replace function f_lay_danh_sach_sach_theo_trang_thai(
	p_trang_thai varchar(50) default 'Đang bán' -- Mặc định là 'Đang bán'
)
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
	-- Kiểm tra trạng thái
	if p_trang_thai not in ('Đang bán', 'Ngừng bán') then
		raise exception 'Trạng thái không hợp lệ: %. Chỉ chấp nhận ''Đang bán'' hoặc ''Ngừng bán''.' , p_trang_thai;
	end if;
	
	return query
	select *
	from sach s
	where s.trang_thai = p_trang_thai
	order by s.ten_sach;
end;
$$ language plpgsql;



create or replace function f_lay_danh_sach_sach_theo_phan_loai(
	p_phan_loai varchar(50) default 'Để bán'
)
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
	-- Kiểm tra phân loại
	if p_phan_loai not in ('Để bán', 'Tham khảo') then
		raise exception 'Phân loại không hợp lệ: %. Chỉ chấp nhận ''Đế bán'' hoặc ''Tham khảo''.', p_phan_loai;
	end if;
	
	return query
	select *
	from sach s
	where s.phan_loai = p_phan_loai
	order by s.ten_sach;
end;
$$ language plpgsql;



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
	select * from sach s;
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

-- Xoá sách
create or replace function f_xoa_sach(
    p_sach_id int
) returns void as
$$
declare
    v_sach_exists boolean;
    v_has_active_order boolean;
begin
    -- Kiểm tra sách có tồn tại
    select exists(select 1 from sach where sach_id = p_sach_id) into v_sach_exists;
    if not v_sach_exists then
        raise exception 'Sách với mã % không tồn tại.', p_sach_id;
    end if;

    -- Kiểm tra xem sách có trong đơn hàng chưa hủy
    select exists(
        select 1
        from chi_tiet_don_hang_sach ctdh
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
        where ctdh.sach_id = p_sach_id
        and (tt.trang_thai is null or tt.trang_thai != 'Đã hủy')
    ) into v_has_active_order;

    if v_has_active_order then
        raise exception 'Không thể xóa sách này vì đã có trong lịch sử giao dịch.';
    end if;

    -- Xóa các bản ghi liên quan trong bảng tac_gia
    delete from tac_gia where sach_id = p_sach_id;

    -- Xóa sách
    delete from sach where sach_id = p_sach_id;
end;
$$ language plpgsql;