USE [bilet_kinowy]
GO
/****** Object:  StoredProcedure [dbo].[pokaż_miejsca4]    Script Date: 21.06.2022 14:16:10 ******/
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
	 declare @id_filmu      as int
	 declare @id_dnia       as int
	 declare @id_repertuaru as int
	 declare @pojemność     as int
-----Przypisanie klucza głównego z tabeli dbo.filmy do zadeklarowanego parametru
	 select @id_filmu = id_filmu 
	   from dbo.filmy 
	  where nazwa_filmu = @nazwa_filmu
-----Przypisanie klucza głównego z tabeli dbo.kalendarz do zadeklarowanego parametru
	 select @id_dnia = id_dnia 
	   from dbo.kalendarz 
	  where dzień = @data_seansu
-----Przypisanie pojemności sali oraz Id_repertuaru. 
	 select @pojemność     = sk.pojemność
		  , @id_repertuaru = r.id_repertuaru 
	   from repertuar		as r
 inner join dbo.sale_kinowe as sk
	     on sk.id_sali = r.id_sali
	  where r.id_filmu = @id_filmu 
		and r.id_dnia  = @id_dnia 
		and r.godzina  = @godzina_seansu
----za sprawą wyrażenia CTE pokazujemy wolne miejsca na wybrany seans
	;with ilość_miejsc as
		 (
			select id_miejsca
			     , id_repertuaru 
		      from dbo.tymczasowa_rezerwacja
			 where id_repertuaru = @id_repertuaru
		 union all
			select id_miejsca
				 , id_repertuaru 
			  from dbo.rezerwacja
			 where id_repertuaru = @id_repertuaru
		 )
			select l.id_liczby as wolne_miejsca
			  from dbo.liczby  as l
			 where l.id_liczby <= @pojemność
			 and not exists 
						   (
							 select lm.id_miejsca 
							   from ilość_miejsc as lm with (nolock)
							  where lm.id_miejsca = l.id_liczby
						   )	
end 
		
		