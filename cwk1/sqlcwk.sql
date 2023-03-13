/*
@author Branson Tay

This is an sql file to put your queries for SQL coursework. 
You can write your comment in sqlite with -- or /* * /

To read the sql and execute it in the sqlite, simply
type .read sqlcwk.sql on the terminal after sqlite3 chinook.db.
*/

/* =====================================================
   WARNNIG: DO NOT REMOVE THE DROP VIEW
   Dropping existing views if exists
   =====================================================
*/
DROP VIEW IF EXISTS vCustomerPerEmployee;
DROP VIEW IF EXISTS v10WorstSellingGenres ;
DROP VIEW IF EXISTS vBestSellingGenreAlbum ;
DROP VIEW IF EXISTS v10BestSellingArtists;
DROP VIEW IF EXISTS vTopCustomerEachGenre;

/*
============================================================================
Question 1: Complete the query for vCustomerPerEmployee.
WARNNIG: DO NOT REMOVE THE STATEMENT "CREATE VIEW vCustomerPerEmployee AS"
============================================================================
*/
CREATE VIEW vCustomerPerEmployee  AS
   SELECT 
      e.LastName AS 'LastName', 
      e.FirstName AS 'FirstName', 
      e.EmployeeId AS 'EmployeeID',
      COUNT(c.SupportRepId) AS 'TotalCustomer'
   FROM employees e
      LEFT JOIN customers c 
      ON e.EmployeeId = c.SupportRepId

   GROUP BY e.EmployeeId
   ;

/*
============================================================================
Question 2: Complete the query for v10WorstSellingGenres.
WARNNIG: DO NOT REMOVE THE STATEMENT "CREATE VIEW v10WorstSellingGenres AS"
============================================================================
*/

CREATE VIEW v10WorstSellingGenres  AS
   SELECT 
      g.Name AS 'Genre', 
      ifnull(sum(ii.Quantity), 0) AS 'Sales'
   FROM genres g
      JOIN tracks t
      ON g.GenreId = t.GenreId
      LEFT JOIN invoice_items ii
      ON t.TrackId = ii.TrackId
   GROUP BY Genre
   ORDER BY Sales ASC LIMIT 10;
   


/*
============================================================================
Question 3:
Complete the query for vBestSellingGenreAlbum
WARNNIG: DO NOT REMOVE THE STATEMENT "CREATE VIEW vBestSellingGenreAlbum AS"
============================================================================
*/
CREATE VIEW vBestSellingGenreAlbum  AS
   SELECT GenreQuery2 AS 'Genre',
      AlbumQuery2 AS 'Album',
      ArtistQuery2 AS 'Artist',
      MAX(QuantityQuery2) AS 'Sales'
         FROM
         (
         SELECT t1.GenreQuery AS 'GenreQuery2', 
         t1.AlbumQuery AS 'AlbumQuery2',
         t1.ArtistQuery AS 'ArtistQuery2',
         SUM(QuantityQuery) AS 'QuantityQuery2'
            -- this table is the "core" table
            FROM
            ( SELECT
            g.Name AS 'GenreQuery',
            a.Title AS 'AlbumQuery', 
            art.Name AS 'ArtistQuery',
            ii.Quantity AS 'QuantityQuery'
            FROM genres g
            JOIN tracks t
               ON g.GenreId = t.GenreId
               JOIN albums a
               ON t.AlbumId = a.AlbumId
               JOIN artists art
               ON a.ArtistId = art.ArtistId
               -- only items sold, included
               JOIN invoice_items ii
               On t.TrackId = ii.TrackId
               ) t1
         GROUP BY t1.AlbumQuery, t1.GenreQuery
         )t2
      WHERE AlbumQuery2 IS NOT NULL
      GROUP BY GenreQuery2
   ;

/*
============================================================================
Question 4:
Complete the query for v10BestSellingArtists
WARNNIG: DO NOT REMOVE THE STATEMENT "CREATE VIEW v10BestSellingArtists AS"
============================================================================
*/
CREATE VIEW v10BestSellingArtists AS
   SELECT
      (SELECT art.Name)
      AS 'Artist',
      (SELECT COUNT(a.AlbumId)
         FROM albums a
         WHERE art.ArtistId = a.ArtistId)
      AS 'TotalAlbum',
      (SELECT count(i.InvoiceLineId)
         FROM tracks t
         JOIN genres g
         ON g.GenreId = t.GenreId
         LEFT JOIN albums a
         ON a.AlbumId = t.AlbumId
         INNER JOIN invoice_items i
         ON t.TrackId = i.TrackId
         WHERE art.ArtistId = a.ArtistId
         ORDER BY count(i.InvoiceLineId) ) AS 'TotalTrackSales'
      FROM artists art
      ORDER BY TotalTrackSales DESC 
      LIMIT 10
      ;

/*
============================================================================
Question 5:
Complete the query for vTopCustomerEachGenre
WARNNIG: DO NOT REMOVE THE STATEMENT "CREATE VIEW vTopCustomerEachGenre AS" 
============================================================================
*/
CREATE VIEW vTopCustomerEachGenre AS
   SELECT 
      -- Genre
      t2.GenreQuery AS 'Genre',
      -- select first name of a customer
      t2.NameQuery AS 'TopSpender',
      -- calculate quantity x unitprice for every invoiceId
      MAX(t2.CalculatedSpending)
         AS 'TotalSpending'
      FROM
      (SELECT 
         g.Name AS 'GenreQuery',
         (
         c.FirstName || ' ' || c.LastName
         ) AS 'NameQuery',
         (SUM(ii.Quantity * ii.UnitPrice)) AS 'CalculatedSpending'
      FROM invoice_items ii
      JOIN invoices i
      ON ii.InvoiceId = i.InvoiceId
      JOIN tracks t
      ON ii.TrackId = t.TrackId
      JOIN customers c
      ON i.CustomerId = c.CustomerId
      JOIN genres g
      ON t.GenreId = g.GenreId
      GROUP BY g.GenreId, c.CustomerId
      ) AS t2
   GROUP BY Genre 
   ORDER BY Genre
      ;

/*
To view the created views, use SELECT * FROM views;
You can uncomment the following to look at invididual views created
*/
SELECT * FROM vCustomerPerEmployee;
SELECT * FROM v10WorstSellingGenres;
SELECT * FROM vBestSellingGenreAlbum ;
SELECT * FROM v10BestSellingArtists;
SELECT * FROM vTopCustomerEachGenre;