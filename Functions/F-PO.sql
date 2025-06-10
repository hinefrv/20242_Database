-- Tạo phiếu nhập mới
create or replace function f_tao_phieu_nhap_moi(
	p_nhan_vien_id int,
	p_nha_cung_cap_id int,
	p_loai_hang varchar(50)
) returns int as
$$
declare
	v_phieu_nhap_id int;
begin
    -- Kiểm tra nhân viên
    if not exists (select 1 from nhan_vien where nhan_vien_id = p_nhan_vien_id) then
        raise exception 'Nhân viên với mã % không tồn tại.', p_nhan_vien_id;
    end if;

    -- Kiểm tra nhà cung cấp
    if not exists (select 1 from nha_cung_cap where nha_cung_cap_id = p_nha_cung_cap_id) then
        raise exception 'Nhà cung cấp với mã % không tồn tại.', p_nha_cung_cap_id;
    end if;

    -- Kiểm tra loại hàng
    if p_loai_hang not in ('Sách', 'Nguyên liệu') then
        raise exception 'Loại hàng không hợp lệ: %. Chỉ chấp nhận ''Sách'' hoặc ''Nguyên liệu''.', p_loai_hang;
    end if;

    -- Tạo phieu_nhap_id
	-- select coalesce(max(phieu_nhap_id), 0) + 1 into v_phieu_nhap_id from phieu_nhap;
    select nextval('phieu_nhap_id_seq') into v_phieu_nhap_id;
	
    -- Chèn phiếu nhập
    insert into phieu_nhap
    values(v_phieu_nhap_id, p_nhan_vien_id, p_nha_cung_cap_id, now(), 0, p_loai_hang);
	
    return v_phieu_nhap_id;
end;
$$ language plpgsql;


-- Thêm chi tiết phiếu nhập sách
create or replace function f_them_chi_tiet_phieu_nhap_sach(
	p_phieu_nhap_id int,
	p_sach_id int,
	p_so_luong int,
	p_gia_nhap numeric(18, 2)
) returns void as
$$
begin
	begin
		-- Kiểm tra phiếu nhập
		if not exists (select 1 from phieu_nhap where phieu_nhap_id = p_phieu_nhap_id and loai_hang = 'Sách') then
			raise exception 'Phiếu nhập với mã % không tồn tại hoặc không phải loại Sách.', p_phieu_nhap_id;
		end if;

		-- Kiểm tra sách
		if not exists (select 1 from sach where sach_id = p_sach_id) then
			raise exception 'Sách với mã % không tồn tại.', p_sach_id;
		end if;

		-- Kiểm tra số lượng
		if p_so_luong <= 0 then
			raise exception 'Số lượng phải là số dương.';
		end if;
	
		-- Kiểm tra giá nhập
		if p_gia_nhap <= 0 then
			raise exception 'Giá nhập phải là số dương.';
		end if;
	
		-- Thêm chi tiết phiếu nhập
		insert into chi_tiet_phieu_nhap_sach
		values (p_phieu_nhap_id, p_sach_id, p_so_luong, p_gia_nhap);

		-- Cập nhật tổng giá nhập
		update phieu_nhap
		set gia_nhap = gia_nhap + (p_so_luong * p_gia_nhap)
		where phieu_nhap_id = p_phieu_nhap_id;

		-- Cập nhật số lượng sách trong kho
		update sach
		set so_luong = so_luong + p_so_luong
		where sach_id = p_sach_id;

	exception
		when others then
			raise exception 'Lỗi khi thêm chi tiết nhập sách: %', sqlerrm;
	end;
end;
$$ language plpgsql;


-- Xoá chi tiết phiếu nhập sách
create or replace function f_xoa_chi_tiet_phieu_nhap_sach(
	p_phieu_nhap_id int,
	p_sach_id int
) returns void as
$$
declare
	v_so_luong int;
	v_gia_nhap numeric(18, 2);
	v_so_luong_kho int;
begin
	begin
		-- Kiểm tra chi tiết
		if not exists (
			select 1 from chi_tiet_phieu_nhap_sach
			where phieu_nhap_id = p_phieu_nhap_id and sach_id = p_sach_id) then
				raise exception 'Chi tiết phiếu nhập với mã % và sách % không tồn tại.', p_phieu_nhap_id, p_sach_id;
		end if;
	
		-- Lấy thông tin
		select so_luong, gia_nhap into v_so_luong, v_gia_nhap
		from chi_tiet_phieu_nhap_sach
		where phieu_nhap_id = p_phieu_nhap_id
			and sach_id = p_sach_id;

		-- Kiểm tra số lượng kho
		select so_luong into v_so_luong_kho from sach where sach_id = p_sach_id;
		if v_so_luong_kho < v_so_luong then
			raise exception 'Không thể xóa: Số lượng trong kho (% cuốn) nhỏ hơn số lượng cần xóa (% cuốn).', v_so_luong_kho, v_so_luong;
		end if;
		
		-- Xoá chi tiết
		delete from chi_tiet_phieu_nhap_sach
		where phieu_nhap_id = p_phieu_nhap_id
			and sach_id = p_sach_id;

		-- Cập nhật tổng giá nhập
		update phieu_nhap
		set gia_nhap = gia_nhap - (v_so_luong * v_gia_nhap)
		where phieu_nhap_id = p_phieu_nhap_id;

		-- Cập nhật số lượng sách trong kho
		update sach
		set so_luong = so_luong - v_so_luong
		where sach_id = p_sach_id;
	exception
		when others then
			raise exception 'Lỗi khi xóa chi tiết phiếu nhập sách: %', sqlerrm;
	end;
end;
$$ language plpgsql;


-- Thêm chi tiết phiếu nhập nguyên liệu
create or replace function f_them_chi_tiet_phieu_nhap_nguyen_lieu(
	p_phieu_nhap_id int,
	p_nguyen_lieu_id int,
	p_so_luong int,
	p_gia_nhap numeric(18, 2)
) returns void as
$$
begin
	begin
		-- Kiểm tra phiếu nhập
		if not exists (select 1 from phieu_nhap where phieu_nhap_id = p_phieu_nhap_id and loai_hang = 'Nguyên liệu') then
			raise exception 'Phiếu nhập với mã % không tồn tại hoặc không phải loại Nguyên liệu.', p_phieu_nhap_id;
		end if;	
	
		-- Kiểm tra nguyên liệu
		if not exists (select 1 from nguyen_lieu where nguyen_lieu_id = p_nguyen_lieu_id) then
			raise exception 'Nguyên liệu với mã % không tồn tại.', p_nguyen_lieu_id;
		end if;

		-- Kiểm tra số lượng
		if p_so_luong <= 0 then
			raise exception 'Số lượng phải là số dương.';
		end if;	
	
		-- Kiểm tra giá nhập
		if p_gia_nhap <= 0 then
			raise exception 'Giá nhập phải là số dương.';
		end if;
	
		-- Thêm chi tiết phiếu nhập
		insert into chi_tiet_phieu_nhap_nguyen_lieu
		values (p_phieu_nhap_id, p_nguyen_lieu_id, p_so_luong, p_gia_nhap);

		-- Cập nhật tổng giá nhập
		update phieu_nhap
		set gia_nhap = gia_nhap + (p_so_luong * p_gia_nhap)
		where phieu_nhap_id = p_phieu_nhap_id;

		-- Cập nhật số lượng nguyên liệu trong kho
		update nguyen_lieu
		set so_luong = so_luong + p_so_luong
		where nguyen_lieu_id = p_nguyen_lieu_id;

	exception
		when others then
			raise exception 'Lỗi khi thêm chi tiết phiếu nhập nguyên liệu: %', sqlerrm;
	end;
end;
$$ language plpgsql;

-- Xoá chi tiết phiếu nhập nguyên liệu
create or replace function f_xoa_chi_tiet_phieu_nhap_nguyen_lieu(
	p_phieu_nhap_id int,
	p_nguyen_lieu_id int
) returns void as
$$
declare
	v_so_luong int;
	v_gia_nhap numeric(18, 2);
	v_so_luong_kho int;
begin
	begin
		-- Lấy thông tin chi tiết
		select so_luong, gia_nhap into v_so_luong, v_gia_nhap
		from chi_tiet_phieu_nhap_nguyen_lieu
		where phieu_nhap_id = p_phieu_nhap_id
			and nguyen_lieu_id = p_nguyen_lieu_id;
		
		-- Xoá chi tiết
		delete from chi_tiet_phieu_nhap_nguyen_lieu
		where phieu_nhap_id = p_phieu_nhap_id
			and nguyen_lieu_id = p_nguyen_lieu_id;
		
		-- Cập nhật tổng giá nhập
		update phieu_nhap
		set gia_nhap = gia_nhap - (v_so_luong * v_gia_nhap)
		where phieu_nhap_id = p_phieu_nhap_id;

		-- Cập nhật số lượng nguyên liệu trong kho
		update nguyen_lieu
		set so_luong = so_luong - v_so_luong
		where nguyen_lieu_id = p_nguyen_lieu_id;

	exception
		when others then
			raise exception 'Lỗi khi xóa chi tiết phiếu nhập nguyên liệu: %', sqlerrm;
	end;
end;
$$ language plpgsql;

-- Xem chi tiết phiếu nhập
create or replace function f_xem_chi_tiet_phieu_nhap(p_phieu_nhap_id int)
returns table (
	loai_hang varchar(20),
	id int,
	ten varchar(255),
	so_luong int,
	don_gia numeric(18, 2),
	thanh_tien numeric(18, 2)
) as
$$
begin
	-- Kiểm tra phiếu nhập tồn tại
    if not exists (select 1 from phieu_nhap where phieu_nhap_id = p_phieu_nhap_id) then
        raise exception 'Phiếu nhập với mã % không tồn tại.', p_phieu_nhap_id;
    end if;
	
	-- Chi tiết sách
	return query
	select 'Sách'::varchar(20) as loai_hang, s.sach_id as id,
			s.ten_sach as ten, ct.so_luong, ct.gia_nhap as don_gia,
			(ct.so_luong * ct.gia_nhap) as thanh_tien
	from chi_tiet_phieu_nhap_sach ct
	join sach s using (sach_id)
	where ct.phieu_nhap_id = p_phieu_nhap_id;

	-- Chi tiết nguyên liệu
	return query
	select 'Nguyên liệu'::varchar(20) as loai_hang, nl.nguyen_lieu_id as id,
			nl.ten_nguyen_lieu as ten, ct.so_luong, ct.gia_nhap as don_gia,
			(ct.so_luong * ct.gia_nhap) as thanh_tien
	from chi_tiet_phieu_nhap_nguyen_lieu ct
	join nguyen_lieu nl using (nguyen_lieu_id)
	where ct.phieu_nhap_id = p_phieu_nhap_id;
end;
$$ language plpgsql;