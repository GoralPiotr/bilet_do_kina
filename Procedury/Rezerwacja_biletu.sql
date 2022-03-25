USE [bilet_kinowy]
GO
/****** Object:  StoredProcedure [dbo].[rezerwacja_biletu4]    Script Date: 24.03.2022 18:11:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* Za sprawą procedury, użytkownik rezerwuje uprzednio wybrane miejsca.
Procedura rezerwuje tylko te miejsca, które zostały zarezerwowane przez
sesję użytkownia. Użytkownik wybiera z trzech rodzajów biletów, od których zależy cena biletu.
Dodatkowo procedura "przyznaje" zniżkę jeśli bilet został zakupiony na seans w odpowiednich godzinach
*/
ALTER proc [dbo].[rezerwacja_biletu4]
(
@email varchar(50),
@rodzaj_biletu1 varchar(10) = 'Normalny',
@rodzaj_biletu2 varchar(10) = 'Normalny',
@rodzaj_biletu3 varchar(10) = 'Normalny'
)
as
begin try
begin tran
declare @id_sesji as int
set @id_sesji = (select @@SPID)
declare @procrezerwująca as dbo.rezerwująca 
----------------------------------------
insert into @procrezerwująca (id_repertuaru,id_miejsca,email)
select 
	 tr.id_repertuaru
	,tr.id_miejsca
	,@email
from dbo.tymczasowa_rezerwacja as tr
where tr.id_sesji = @id_sesji
--and tr.id_miejsca not in (select id_miejsca from dbo.rezerwacja
--where id_repertuaru in (select id_repertuaru from dbo.tymczasowa_rezerwacja))
----------------------------------------
delete from tymczasowa_rezerwacja
where id_sesji = @id_sesji
----------------------------------------
update @procrezerwująca
set id_rodzaju_biletu  = (select id_rodzaju_biletu from rodzaje_biletów 
							where nazwa_biletu = @rodzaj_biletu1)
where id = 1
----------------------------------------
update @procrezerwująca
set id_rodzaju_biletu  = (select id_rodzaju_biletu from rodzaje_biletów 
							where nazwa_biletu = @rodzaj_biletu2)
where id = 2
----------------------------------------
update @procrezerwująca
set id_rodzaju_biletu  = (select id_rodzaju_biletu from rodzaje_biletów 
								where nazwa_biletu = @rodzaj_biletu3)
where id = 3
----------------------------------------
insert into rezerwacja2(id_repertuaru, id_miejsca,email,id_rodzaju_biletu)
select id_repertuaru, id_miejsca,email,id_rodzaju_biletu from @procrezerwująca
----------------------------------------
--waitfor delay '00:00:30'
commit
----------------------------------------
declare @suma as smallmoney
set @suma = (
				select 
					sum(rb.cena_biletu) 
				from @procrezerwująca as r 
				inner join dbo.rodzaje_biletów as rb
				on rb.id_rodzaju_biletu = r.id_rodzaju_biletu
			)
declare @godzina_seansu as time(0)
set @godzina_seansu = (
						select 
							top 1 godzina 
						from @procrezerwująca as rr 
						inner join dbo.repertuar as r
						on rr.id_repertuaru = r.id_repertuaru
					  )
declare @zniżka as smallmoney
if @godzina_seansu < '15:30'
	begin
		set @zniżka = 0.25
	end
else
	begin
		set @zniżka = 0
	end
select ceiling(@suma - (@suma * @zniżka)) as 'kwota do zapłaty'
end try
begin catch
rollback
print 'Coś poszło nie tak'
--;throw
end catch