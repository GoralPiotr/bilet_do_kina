USE [bilet_kinowy]
GO
/****** Object:  StoredProcedure [dbo].[wybór_miejsca]    Script Date: 13.03.2022 18:00:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	Za sprawą procedury użytkownik wybiera miejca na dany seans.
	Użytkownik może wybrać tylko trzy miejsca bez późniejszej rezerwacji.
	Procedura ma za zadanie sprawdzić: czy są one dostępne,
	czy czas wyboru nie minął (max do 15 minut przed seansem).
	
*/
ALTER     proc [dbo].[wybór_miejsca]
(
	@nazwa_filmu as varchar(50),
	@data_seansu as date,
	@godzina_seansu as varchar(5),
	@miejsce1 as int,
	@miejsce2 as int = null,
	@miejsce3 as int = null
	)
as
begin 
set lock_timeout 0
		if datediff(minute,getdate(),(concat(@data_seansu,' ',@godzina_seansu))) >= 15 
			begin
				print 'Bilety można rezerwować do 15 min przed seansem'
			end
		else
			begin
				raiserror ('Rezerwacja już niemożliwa. Tylko do 15 minut przed seansem',11,1)
				return -1 
			end
end
begin 
if (select COUNT(id_sesji) from tymczasowa_rezerwacja
		where id_sesji = @@spid) < 3
		begin
				print 'Można rezerwować'
			end
		else
			begin
				raiserror ('Możesz wybrać 3 miejsca. Zarezerwuj swój wybór',11,1)
				return -1 
			end
end
begin try
begin tran
		declare @id_sesji as int
			select @id_sesji = @@spid
		declare @id_filmu as int
			select @id_filmu = id_filmu from filmy where nazwa_filmu = @nazwa_filmu
		declare @id_dnia as int
			select @id_dnia = id_dnia from kalendarz where dzień = @data_seansu
		declare @id_repertuaru as int
		declare @pojemność as int
			select 
				 @pojemność = sk.pojemność
				,@id_repertuaru = r.id_repertuaru 
			from repertuar as r
			inner join sale_kinowe as sk
			on sk.id_sali = r.id_sali
				where r.id_filmu = @id_filmu 
				and r.id_dnia = @id_dnia and r.godzina = @godzina_seansu	
begin	
		if @miejsce1 > @pojemność or @miejsce1 < 1
			begin
				raiserror ('wybrano niepoprawne miejsce',11,1)
			end
		else 
				if @miejsce1 in (select id_miejsca from rezerwacja
								where id_repertuaru = @id_repertuaru)
					begin
						raiserror ('miejsce zostało wcześniej zarezerwowane',11,1)
					end
				else 
					if @miejsce2 is null
							begin
								print 'miejsce2 niewybrane'
								insert into tymczasowa_rezerwacja (id_repertuaru,id_miejsca,id_sesji)
							    values(@id_repertuaru,@miejsce1,@id_sesji)
							end
					else 
						if @miejsce2 > @pojemność or @miejsce2 < 1
							begin
								raiserror ('wybrano niepoprawne miejsce',11,1)
							end
						else 			
							if @miejsce2 in (select id_miejsca from rezerwacja
											where id_repertuaru = @id_repertuaru)
							begin
								raiserror ('miejsce zostało wcześniej zarezerwowane',11,1)
							end

							else 
									if @miejsce3 is null
									begin
										print 'miejsce3 niewybrane'
											insert into tymczasowa_rezerwacja (id_repertuaru,id_miejsca,id_sesji)
											values(@id_repertuaru,@miejsce1,@id_sesji),
												  (@id_repertuaru,@miejsce2,@id_sesji)
									end
									
									else 
										if @miejsce3 > @pojemność or @miejsce3 < 1
												begin
													raiserror ('wybrano niepoprawne miejsce',11,1)
												end
										else
																	
												if @miejsce3  in (select id_miejsca from rezerwacja
																where id_repertuaru = @id_repertuaru)
												begin
													raiserror ('miejsce zostało wcześniej zarezerwowane',11,1)
												end

												else 
																			
														insert into tymczasowa_rezerwacja (id_repertuaru,id_miejsca,id_sesji)
														values(@id_repertuaru,@miejsce1,@id_sesji),
															  (@id_repertuaru,@miejsce2,@id_sesji),
														      (@id_repertuaru,@miejsce3,@id_sesji)
--waitfor delay '00:00:15'
commit		
end	
end try
begin catch
rollback tran
print 'brak rezerwacji. Sprawdź dostępność miejsca'
;throw
end catch 

