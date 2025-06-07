-- Báo cáo tồn kho chi tiết
create or replace function f_bao_cao_ton_kho()
returns table (
	loai_san_pham varchar(20),
	id int,
	ten varchar(255),
	so_luong int,
	don_vi_tinh varchar(20),
	nguong_canh_bao int,
	trang_thai varchar(50)
) as
$$
begin
	return query
	select 'Sách'::varchar(20) as loai_san_pham, s.sach_id as id,
			s.ten_sach as ten, s.so_luong, 'cuốn'::varchar(20) as don_vi_tinh,
			s.nguong_toi_thieu as nguong_canh_bao, s.trang_thai::varchar(50)
	from sach s;

	return query
	select 'Nguyên liệu'::varchar(20) as loai_san_pham, nl.nguyen_lieu_id as id,
			nl.ten_nguyen_lieu as ten, nl.so_luong,
			nl.don_vi_tinh::varchar(20), nl.nguong_canh_bao,
			case
				when nl.so_luong < nl.nguong_canh_bao then 'Cần nhập thêm'::varchar(50)
				else 'Đủ'::varchar(50)
			end as trang_thai
	from nguyen_lieu nl;
end;
$$ language plpgsql;

-- Cảnh báo tồn kho thấp
create or replace function f_canh_bao_ton_kho_thap()
returns table (
	nguyen_lieu_id int,
	ten_nguyen_lieu varchar(100),
	so_luong int,
	don_vi_tinh varchar(20),
	nguong_canh_bao int,
	chenh_lech int
) as
$$
begin
	return query
	select nl.nguyen_lieu_id, nl.ten_nguyen_lieu, nl.so_luong, nl.don_vi_tinh,
			nl.nguong_canh_bao, (nl.so_luong - nl.nguong_canh_bao) as chenh_lech
	from nguyen_lieu nl
	where nl.so_luong < nl.nguong_canh_bao
	order by chenh_lech asc;
end;
$$ language plpgsql;

-- Điều chỉnh tồn kho sách
create or replace function f_dieu_chinh_ton_kho_sach(
	p_sach_id int,
	p_so_luong_moi int
) returns void as
$$
begin
	update sach
	set so_luong = p_so_luong_moi
	where sach_id = p_sach_id;
end;
$$ language plpgsql

-- Điều chỉnh tồn kho nguyên liệu
create or replace function f_dieu_chinh_ton_kho_nguyen_lieu(
	p_nguyen_lieu_id int,
	p_so_luong_moi int
) returns void as
$$
begin
	update nguyen_lieu
	set so_luong = p_so_luong_moi
	where nguyen_lieu_id = p_nguyen_lieu_id;
end;
$$ language plpgsql;