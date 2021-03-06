USE [bilet_kinowy]
GO
/****** Object:  UserDefinedFunction [dbo].[Wyświetlane_filmy2]    Script Date: 21.06.2022 20:04:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Funkcja inline za srawą której możemy wyświetlić repertuar
*/
ALTER   function [dbo].[Wyświetlane_filmy2]
(
@dzień as date
)
returns table
return
		    select f.Nazwa_filmu
			 , r.godzina
			 , k.dzień
		      from dbo.repertuar as r
                inner join dbo.filmy     as f
		        on f.id_filmu = r.id_filmu
                inner join kalendarz     as k
		        on k.id_dnia  = r.id_dnia
	             where k.dzień    = @dzień