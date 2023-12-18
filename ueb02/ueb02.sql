-- 1: Finden Sie alle Aufgaben, deren Bestandteil die "Administration" von irgendetwas ist.
select *
from   aufgabe
where  aufgabe_bez like "%administration%";

-- 2: Finden Sie alle Postleitzahlen die es im Ort Hamburg gibt.
select distinct plz
from   adresse
where  ort = 'Hamburg';

-- 3: Geben Sie an wie viele Mitarbeiter einen Doktortitel tragen.
select Count(titel) as 'Doktoren'
from   mitarbeiter
where  titel like "%dr.%";

-- 4: Zeigen sie alle Buchveröffentlichungen auf die eines der folgenden Kriterien zutrifft: 
-- Veröffentlicht zwischen 2003 und 1989, Titel enthält den Begriff "geheim" und "Tagebuch", Titel enthält den Begriff "Faszination".
select *
from   veroeffentlichung
where  (jahr <= 2003 and jahr >= 1989) or 
	   (buchtitel like '%geheim%'and buchtitel like '%Tagebuch%') or
       (buchtitel like '%Faszination%');

-- 5: Benennen Sie alle Räume, die weniger als 100 Plätze haben und weder Labore noch Rechenzentren sind.
select *
from   raum
where  	   (plaetze < 100) and 
	   not (raum_bez like "%labor%") and
	   not (raum_bez like "%rechenzentrum%");

-- 6: Finden Sie heraus, wann der Hörsaal 2 am Dienstag noch zur Verfügung steht.
select block.STARTZEIT , block.ENDZEIT
from block join (select block.BLOCK
				from block
				except
				select *
				from (select termin.BLOCK
					from raum join veranst_termin on raum.RAUM_ID = veranst_termin.RAUM_ID
					join termin on veranst_termin.TERMIN_ID = termin.TERMIN_ID
					join tag on termin.TAG = tag.TAG
					where raum.RAUM_BEZ = "Hörsaal 2" and tag.WOCHENTAG = "Dienstag") as block) as t on block.BLOCK = t.BLOCK;
 
-- 7: Gebt alle bestandenen Leistungen (teilgenommen und Note kleiner 5) des Studenten Jan-Claas Brade aus.
select pruefung.note,
       studienleistung.sl_name
from   studienleistung
       join pruefung on studienleistung.studienleistung_id = pruefung.studienleistung_id
       join student on pruefung.pin = student.pin
       join person on student.pin = person.pin
where  person.vname = 'Jan-Claas'
       and person.nname = 'Brade'
       and pruefung.teilnahme = 'J'
       and pruefung.note < 5;

-- 8: Nennt die Prüfungen (Bezeichnung) in denen ein Student (vollständiger Name) aus Pinneberg (PLZ 25421) schon einmal durchgefallen ist (angetreten und Note >= 5).
select distinct person.vname,
                person.nname,
                studienleistung.sl_name
from   studienleistung
       join pruefung on studienleistung.studienleistung_id = pruefung.studienleistung_id
       join student on pruefung.pin = student.pin
       join person on student.pin = person.pin
       join adresse on person.pin = adresse.pin
where  adresse.plz = 25421
       and pruefung.note >= 5
       and pruefung.teilnahme = 'J';

-- 9: Zählen Sie wieviele Räume es von jeder Raumart gibt. Geben sie Raumart, raumart_bez und die Anzahl an. 
select raumart,
       Count(*)
from   raum
group  by raumart;

-- 9.1: Theoretische Aufgabe: Wenn es x Raumarten gibt, wieviele Zeilen hat die Lösung? Antwort: x viele
-- 10: Finden sie heraus, wie viele Prüfungen bei den verschiedenen Dozenten geschrieben wurden.
select mitarbeiter.kuerzel,
       Count(*)
from   pruefung
       join person on pruefung.mit_pin = person.pin
       join mitarbeiter on person.pin = mitarbeiter.pin
       join dozent on mitarbeiter.pin = dozent.pin
where  pruefung.note > 0
group  by mitarbeiter.kuerzel;

-- 11: Finden Sie alle Veranstaltungen, deren ECTS Punktzahl mehr als doppelt so hoch ist wie die durchschnittliche ECTS Punktzahl.
select distinct v.veranstaltung_bez,
                v.veranstaltung_id,
                vs.ects
from   veranstaltung as v
       join veranstaltung_studienleistung as vs on v.veranstaltung_id = vs.veranstaltung_id
where  (vs.ects) > (select Avg(ects)
                      from   veranstaltung_studienleistung) * 2;

-- 12: Nenne den jüngsten Studenten (Vorname, Nachname, Geburtsdatum).
select person.vname,
       person.nname,
       person.gebdat
from   person
       join student on person.pin = student.pin
where  gebdat = (select Max(gebdat)
                 from   person);

-- 13: Berechnet die Durchschnittsnote des Studenten mit der Pinnummer '3117' auf eine Nachkommastelle gerundet.
select Round(Avg(note), 1) as Note
from   person
       join student
         on person.pin = student.pin
       join pruefung
         on student.pin = pruefung.pin
where  person.pin = '3117';

-- 14: Gebt bitte den Aufgabenbezeichner, Vorname und Nachname der Personen aus, welche das Medien Rechenzentrum betreuen und für die Buchhaltung zuständig sind.
select aufgabe.aufgabe_bez,
       person.vname,
       person.nname
from   ( person
         join mitarbeiter on person.pin = mitarbeiter.pin
         join sonst_mit on sonst_mit.pin = mitarbeiter.pin
         join aufgabe on sonst_mit.aufgabe_id = aufgabe.aufgabe_id )
where  aufgabe.aufgabe_bez = 'Buchhaltung'
union
select aufgabe.aufgabe_bez,
       person.vname,
       person.nname
from   person
       join mitarbeiter on person.pin = mitarbeiter.pin
       join assistent on assistent.pin = mitarbeiter.pin
       join aufgabe on assistent.aufgabe_id = aufgabe.aufgabe_id
       join betreut on assistent.pin = betreut.pin
where  aufgabe.aufgabe_bez = 'Medien-RZ';

-- 15: Berechne das größte und kleinste ausgezahlte Bafög aller Studenten.
select Max(bafoeg),
       Min(bafoeg)
from   student;

-- 16: Gebt die Krankenkassen mit den meisten versicherten Personen aus.
select *
from   (select k.kk_name        as BEZ,
               Count(k.kk_name) as gesamt
        from   person as p
               join krankenkasse as k on p.krankenkasse_id = k.krankenkasse_id
        group  by k.kk_name) as t
order  by gesamt desc;

-- 17: Gebt die Anzahl aller Studenten im ersten Verwaltungssemester aus.
select Count(*)
from   student
where  verwsem = 1;

-- 18: Welche Gehälter werden an der Hochschule pro Jahr durchschnittlich (2 Nachkommastellen), maximal, minimal und aufsummiert gezahlt? Beachten sie auch die Zahlung des Weihnachtsgeldes.
select Cast(12 * ( Avg(gehaltsstufe.gehalt) ) + Avg(gehaltsstufe.weihnachtsgeld) as DECIMAL(10, 2)) as durchschnitt,
       Max(( 12 * gehaltsstufe.gehalt ) + gehaltsstufe.weihnachtsgeld) as Maximal,
       Min(( 12 * gehaltsstufe.gehalt ) + gehaltsstufe.weihnachtsgeld) as Minmal
from   mitarbeiter
       join gehaltsstufe on mitarbeiter.gehaltsstufe_id = gehaltsstufe.gehaltsstufe_id;

-- 19: Wie viele weibliche Studenten sind in den den vorhandenen Fachrichtungen eingeschrieben?
select fachrichtung.fr_bez,Count(*)
from   (select *
       from   person
	   where  person.geschlecht = 'W') as p
	   join student on p.pin = student.pin
	   join fachrichtung on fachrichtung.fachrichtung_id = student.fachrichtung_id
group  by fachrichtung.fr_bez;

-- 20: Finden Sie heraus, wieviele Studenten in Wohngemeinschaften leben. Als WG ist dabei jede Adresse zu zählen, bei der Straße und PLZ identisch sind.
select count(Mitglieder)
from (select adresse.PLZ,adresse.STRASSE,count(*) as Mitglieder
	  from adresse join person on adresse.PIN = person.PIN
	  join student on person.PIN = student.PIN
	  group by adresse.STRASSE,adresse.PLZ
	  having count(*) > 1) as t ;

-- 21: Gebt bitte die Veranstaltungsanzahl des Tages aus, der pro Woche die meisten Veranstaltungen hat. 
-- Gebt außerdem noch die Anzahl der Veranstaltungen des Tages mit den geringsten Veranstaltungen aus. 
-- Des Weiteren gebt bitte die Summe aller Veranstaltungen und die durchschnittliche Zahl aller Veranstaltungen pro Tag aus aus.
select Max(t.ANZAHL),Min(t.ANZAHL),sum(t.ANZAHL),avg(t.Anzahl)
from (
select tag.WOCHENTAG,count(veranst_termin.VERANSTALTUNG_ID) as ANZAHL
from veranst_termin join veranstaltung on veranst_termin.VERANSTALTUNG_ID = veranstaltung.VERANSTALTUNG_ID 
join termin on veranst_termin.TERMIN_ID = termin.TERMIN_ID
join tag on termin.TAG = tag.TAG
group by tag.WOCHENTAG) as t;

-- 22: Berechnen sie wie hoch der prozentuale Frauenanteil in den Fachrichtungen Wirtschaftsinformatik und technischer Informatik ist.
select (frauenT.anzahl / alleT.anzahl) * 100 as Technische_Informatik_Frauenanteil,
	   (frauenW.anzahl / alleW.anzahl) * 100 as Wirtschaftsinformatik_Frauenanteil,
       ((frauenT.anzahl+frauenW.anzahl) / (alleW.anzahl+alleT.anzahl)) *100 as Frauenanteil
from (
	select count(*) as anzahl
	from   person join student on person.PIN = student.PIN
	join fachrichtung on student.FACHRICHTUNG_ID = fachrichtung.FACHRICHTUNG_ID
	where   fr_bez like 'Technische Informatik%' ) as alleT,
    (select count(*) as anzahl
	from   person join student on person.PIN = student.PIN
	join fachrichtung on student.FACHRICHTUNG_ID = fachrichtung.FACHRICHTUNG_ID
	where  fr_bez like 'Wirtschaftsinformatik%') as alleW,
    (select count(*) as anzahl
	from   person join student on person.PIN = student.PIN
	join fachrichtung on student.FACHRICHTUNG_ID = fachrichtung.FACHRICHTUNG_ID
	where person.GESCHLECHT= 'W' and fr_bez like 'Technische Informatik%') as frauenT,
    (select count(*) as anzahl
	from   person join student on person.PIN = student.PIN
	join fachrichtung on student.FACHRICHTUNG_ID = fachrichtung.FACHRICHTUNG_ID
	where person.GESCHLECHT= 'W' and fr_bez like 'Wirtschaftsinformatik%') as frauenW;

-- 23: Bilden Sie alle möglichen Paare aus Veröffentlichungen, die im gleichen Jahren erschienen sind. Nennen Sie jeweils die Jahre der Veröffentlichungen sowie die Titel.
select distinct veroeffentlichung.Buchtitel AS Buch1,veroeffentlichung2.BUCHTITEL AS Buch2,veroeffentlichung.JAHR
from veroeffentlichung ,veroeffentlichung AS veroeffentlichung2
where veroeffentlichung.jahr and veroeffentlichung2.jahr in (select jahr
															 from veroeffentlichung
															 group by jahr
															 having count(Jahr)> 1)
and (veroeffentlichung.jahr =  veroeffentlichung2.jahr) and (veroeffentlichung.Pin !=  veroeffentlichung2.Pin)
order by veroeffentlichung.JAHR asc ;

-- 24: Finden Sie alle Räume, die eine Auslastung <= 25% innerhalb einer Woche haben (gemessen an der Belegungen von Zeitslots).
	-- Die Ausgabe soll die Raumbezeichnung und die Auslastung in Prozent beinhalten. 
    -- Die Auslastung berechnet sich anhand der stattfindenden Veranstaltungen je Raum.
	-- Bei einer Woche mit sieben Zeitslots an sieben Tagen entspräche eine Belegung mit 49 Veranstaltungen 100%. 
	-- Hinweis: Räume können zu einem Zeitpunkt mehrfach belegt sein, was bei Nichtberücksichtigung zu Auslastungen > 100% führen kann.
	-- Berücksichtigen Sie jeden belegten Zeitblock daher nur einmalig.
    
select *
from (
select   raum.RAUM_BEZ , (count( distinct termin.TERMIN_ID)) * 100 / (Anzahl_tage.Anzahl *Anzahl_Blöcke.Anzahl ) AS Auslastung_in_Prozent

from raum join veranst_termin on raum.RAUM_ID = veranst_termin.RAUM_ID 
join termin on termin.Termin_ID = veranst_termin.TERMIN_ID
join tag on tag.TAG = termin.TAG
join block on block.Block = termin.BLOCK

 join (select count(block.BLOCK) AS Anzahl
from block) AS Anzahl_Blöcke

join (select count(*) AS Anzahl
from tag) AS Anzahl_tage

group by raum.RAUM_BEZ,Anzahl_tage.Anzahl,Anzahl_Blöcke.Anzahl ) AS Raum_Prozente
where Raum_Prozente.Auslastung_in_Prozent < 25;

-- 25: Finden Sie alle Studenten, auf die mindestens eine der im folgenden genannten Bedingungen zutrifft. Verwenden Sie zur Formulierung jeder Bedingungen eine Unterabfrage. 
	-- Ihre oberste Abfrage darf nur aus den Tabellen "Person" und "Student" Daten beziehen. 
	-- * Ist bei mehr als einer Prüfungsteilnahme erkrankt. 
	-- * Ist versichert bei einer Krankenkasse mit mehr als 146 Mitgliedern.

select person.VNAME, person.NNAME 
from person join student on person.PIN = student.PIN

where person.pin in (
select pin
from pruefung
where TEILNAHME = 'K'
group by PIN
having count(TEILNAHME) > 1) 
or 
person.KRANKENKASSE_ID in  ( 
select krankenkasse.KRANKENKASSE_ID
from krankenkasse join person on krankenkasse.KRANKENKASSE_ID = person.KRANKENKASSE_ID
group by krankenkasse.KK_NAME, krankenkasse.KRANKENKASSE_ID
having count(person.Pin) > 146)

;
-- 26: Für die FH Wedel soll eine Singlebörse eingerichtet werden. Dafür braucht man eine Liste von allen möglichen Paaren.
	-- Für Testzwecke werden zuerst alle Paare von Mitarbeitern gebildet.
	-- Geben Sie die Vorund Nachnamen an.
    -- Es soll eine Spalte mit angegeben werden, ob die Paarungen gleichgeschlechtlich sind oder nicht.
select person.Pin,person.VNAME ,person.NNAME , person.GESCHLECHT ,Person2.pin AS Pin2 ,Person2.VNAME AS VNAME2,Person2.NNAME AS NNAME2, Person2.GESCHLECHT AS Geschlecht2 , if(person.GESCHLECHT = Person2.GESCHLECHT , 'Gleich' , 'ungleich') AS Gleichgeschlechtlich
from person join mitarbeiter on mitarbeiter.pin = person.pin,(

select person.Pin,VNAME,NNAME,GESCHLECHT
from person join mitarbeiter on mitarbeiter.pin = person.pin
) AS Person2

 where person.NNAME != Person2.NNAME;