USE [bilet_kinowy]
GO  
/****** Object:  StoredProcedure [dbo].[wybór_miejsca]    Script Date: 04.07.2022 13:07:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	Za sprawą procedury użytkownik wybiera miejca na dany seans.
	Włączenie pocedury to wybór jednego miejsca. Ponowny wybór tego 
	samego miejsca spowoduje usunięcie wybranego miejsca uprzednio. 
	Procedura ma za zadanie sprawdzić: czy są one dostępne,
	czy czas wyboru nie minął (max do 15 minut przed seansem).
*/
ALTER proc [dbo].[wybór_miejsca]
(
	@nazwa_filmu as varchar(50),
	@data_seansu as date,
	@godzina_seansu as time(0),
	@miejsce as int
	)
as
begin try
begin tran
begin 
--set lock_timeout 0
-------------------
declare @id_sesji as smallint 
		select @id_sesji   = @@spid
declare @id_filmu as smallint
		select @id_filmu = id_filmu 
		  from dbo.filmy 
		 where nazwa_filmu = @nazwa_filmu
declare @id_dnia as smallint
		select @id_dnia = id_dnia 
		  from dbo.kalendarz 
	     where dzień = @data_seansu		
declare @id_repertuaru as int
declare @pojemność as smallint
----------------------------------------
	select @id_repertuaru = r.id_repertuaru
		 , @pojemność     = sk.pojemność
	  from dbo.repertuar   as r
inner join dbo.sale_kinowe as sk
	    on sk.id_sali = r.id_sali
	 where r.id_filmu = @id_filmu 
	   and r.id_dnia  = @id_dnia 
	   and r.godzina  = @godzina_seansu
------------------------------------------
declare @licz_id as smallint
set @licz_id = (
				 select count(id_sesji) 
				   from dbo.tymczasowa_rezerwacja
				  where id_sesji = @id_sesji
				)
------------------------------------------
	if datediff(minute,getdate(),(concat_ws(' ',@data_seansu,@godzina_seansu))) < 15
	begin
		select 'Wybór możliwy tylko do 15 minut' as komunikat
	end
	else
		if @miejsce > @pojemność or @miejsce < 1
				begin
					select 'Miejsce niepoprawne' as komunikat 
				end
		else 
			if exists(
					   select id_miejsca 
			             from dbo.rezerwacja 
				        where id_repertuaru = @id_repertuaru 
					      and id_miejsca    = @miejsce
					  )
			begin
				Select 'Miejsce już zarezerwowne' as komunikat
			end
		else
		begin
				if exists 
						   (
							select id_miejsca 
							  from dbo.tymczasowa_rezerwacja 
							 where id_repertuaru = @id_repertuaru 
							   and id_miejsca    = @miejsce 
							   and id_sesji      <> @id_sesji
							)
					begin 
						Select 'Miejsce już wybrane przez inną osobę' as komunikat
					end
				else 
					begin
						if exists 
						   (
								select id_miejsca 
								  from dbo.tymczasowa_rezerwacja 
								 where id_repertuaru = @id_repertuaru 
								   and id_miejsca = @miejsce 
								   and id_sesji = @id_sesji
							)
							begin 
								delete from dbo.tymczasowa_rezerwacja
									  where id_sesji      = @id_sesji 
									    and id_miejsca    = @miejsce 
										and id_repertuaru = @id_repertuaru
								Select 'Usunięto miejsce nr  '+ cast(@miejsce as char(3)) as wybór
							end
							else
							begin
								if @licz_id <3
									begin
										insert into dbo.tymczasowa_rezerwacja (id_repertuaru,id_miejsca,id_sesji) 
										values(@id_repertuaru,@miejsce,@id_sesji)
										Select 'Wybrano miejsce nr  '+ cast(@miejsce as char(3)) as wybór
									end
								else 
									begin
										select 'Możesz wybrać tylko 3 miejsca' as komunikat
									end
							end
					end
		end
--waitfor delay '00:00:45'
commit		
----------------------------------------
end	
end try
	begin catch
	rollback tran
	print 'brak rezerwacji. Sprawdź dostępność miejsca'
	--;throw
end catch 

