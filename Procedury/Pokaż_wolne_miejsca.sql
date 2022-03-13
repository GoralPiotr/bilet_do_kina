USE [bilet_kinowy]
GO
/****** Object:  StoredProcedure [dbo].[pokaż_miejsca4]    Script Date: 13.03.2022 17:24:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Zadaniem procedury jest pokazanie użytkownikowi wolnych miejsc na wskazany seans
*/
ALTER     proc [dbo].[pokaż_miejsca4] 
(
@nazwa_filmu as varchar(50),
@data_seansu as date,
@godzina_seansu as time(0)
)
as
begin
declare @id_filmu as int
declare @id_dnia as int
declare @id_repertuaru as int
declare @pojemność as int
select 
		@id_filmu = id_filmu 
from dbo.filmy 
where nazwa_filmu = @nazwa_filmu
;
		select 
			@id_dnia = id_dnia 
		from dbo.kalendarz 
		where dzień = @data_seansu
		;
			select 
				 @pojemność = sk.pojemność
				,@id_repertuaru = r.id_repertuaru 
			from repertuar as r
			inner join dbo.sale_kinowe as sk
			on sk.id_sali = r.id_sali
			where r.id_filmu = @id_filmu 
				and r.id_dnia = @id_dnia 
				and r.godzina = @godzina_seansu
;with ilość_miejsc as
		 (
			select 
				   id_miejsca
			      ,id_repertuaru 
		    from dbo.tymczasowa_rezerwacja
			
  union all
			select 
				  id_miejsca
				 ,id_repertuaru 
			from dbo.rezerwacja 
		 )
			select 
				  id_liczby as wolne_miejsca
			from dbo.liczby as l
			where id_liczby not in 
							 (select 
								   id_miejsca 
							  from ilość_miejsc as lm with (nolock)
							  where id_repertuaru = @id_repertuaru
							  )
			and l.id_liczby <= @pojemność	
end 
		
		