/*
SQL QUERIES FOR DATA CLEANING OF HOUSING DATASET
*/

--1)QUERY TO SELECT ALL THE DATA FROM Housing_Data TABLE
SELECT *
FROM Tutorial_Project.dbo.Housing_Data


--2)QUERY TO OBTAIN THE CORRECT FORMAT OF DATE
SELECT CONVERT(date,h.SaleDate) AS Date
FROM Tutorial_Project.dbo.Housing_Data AS h

UPDATE Tutorial_Project.dbo.Housing_Data
SET SaleDate = CONVERT(date,SaleDate)


--3)QUERY TO FILL IN THE PROPERTY ADDRESS WHERE IT IS NULL
  --The idea is that the cells where property address is null, we have to fill in that address which has a certain value in the table which is same for both.

    SELECT *																													--To obtain all the records where PropertyAddress is null
	FROM Tutorial_Project.dbo.Housing_Data
	WHERE PropertyAddress IS NULL

	SELECT h1.ParcelID,h1.PropertyAddress, h2.ParcelID, h2.PropertyAddress, ISNULL(h1.PropertyAddress, h2.PropertyAddress)		--To compare PropertAddresses based on their ParcelID
	FROM Tutorial_Project.dbo.Housing_Data AS h1
	JOIN Tutorial_Project.dbo.Housing_Data as h2
	ON h1.ParcelID = h2.ParcelID
	WHERE h1.UniqueID <> h2.UniqueID AND h1.PropertyAddress IS NULL

	UPDATE h1																													--To update the table and assign value to PropertyAddress where it is null
	SET PropertyAddress = ISNULL(h1.PropertyAddress, h2.PropertyAddress)
	FROM Tutorial_Project.dbo.Housing_Data AS h1
	JOIN Tutorial_Project.dbo.Housing_Data as h2
	ON h1.ParcelID = h2.ParcelID
	WHERE h1.UniqueID <> h2.UniqueID AND h1.PropertyAddress IS NULL


--4)QUERY TO SEPARATE THE HOUSE ADDRESS AND CITY FROM PROPERTY ADDRESS
SELECT h.PropertyAddress
FROM Tutorial_Project.dbo.Housing_Data AS h

	SELECT																														--Separating House Address, Lane and City
	SUBSTRING(h.PropertyAddress, 1, CHARINDEX(',', h.PropertyAddress) - 1) AS HouseAddress,
	SUBSTRING(h.PropertyAddress, CHARINDEX(',', h.PropertyAddress) + 1, LEN(h.PropertyAddress)) AS City
	FROM Tutorial_Project.dbo.Housing_Data AS h

	ALTER TABLE Tutorial_Project.dbo.Housing_Data
	ADD HouseAddress nvarchar(255)

	UPDATE Tutorial_Project.dbo.Housing_Data
	SET HouseAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

	ALTER TABLE Tutorial_Project.dbo.Housing_Data
	ADD City nvarchar(255)

	UPDATE Tutorial_Project.dbo.Housing_Data
	SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


--5)QUERY TO SEPARATE THE HOUSE ADDRESS, CITY AND STATE FROM OWNER ADDRESS
SELECT h.OwnerAddress
FROM Tutorial_Project.dbo.Housing_Data AS h

  --This can be also done in the same way as we did in the above query but here we will be using the PARSENAME function as there are more than two commas. This reduce the complexity of the query
	SELECT PARSENAME(REPLACE(h.OwnerAddress,',','.'), 3) AS Owner_Address,
	PARSENAME(REPLACE(h.OwnerAddress,',','.'), 2) AS Owner_City,
	PARSENAME(REPLACE(h.OwnerAddress,',','.'), 1) AS Owner_State
	FROM Tutorial_Project.dbo.Housing_Data AS h

	ALTER TABLE Tutorial_Project.dbo.Housing_Data
	ADD Owner_Address nvarchar(255)

	UPDATE Tutorial_Project.dbo.Housing_Data
	SET Owner_Address = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

	ALTER TABLE Tutorial_Project.dbo.Housing_Data
	ADD Owner_City nvarchar(255)

	UPDATE Tutorial_Project.dbo.Housing_Data
	SET Owner_City = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

	ALTER TABLE Tutorial_Project.dbo.Housing_Data
	ADD Owner_State nvarchar(255)

	UPDATE Tutorial_Project.dbo.Housing_Data
	SET Owner_State = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)


--6)QUERY TO REPLACE Y AND N WITH YES AND NO RESPECTIVELY IN SoldAsVacant COLUMN
  --We will be doing this using the CASE statement. Also there are two ways of doing this while using the CASE statement

    --6.1)Standard way of writing CASE Statement
	SELECT h.SoldAsVacant, CASE WHEN h.SoldAsVacant = 'Y' THEN 'Yes'
							WHEN h.SoldAsVacant = 'N' THEN 'No' 
							ELSE h.SoldAsVacant
							END AS Sold_As_Vacant
	FROM Tutorial_Project.dbo.Housing_Data AS h

    --6.2)Using REPLACE function
	SELECT h.SoldAsVacant, CASE WHEN h.SoldAsVacant = 'Y' THEN REPLACE(h.SoldAsVacant,'Y','Yes')
							WHEN h.SoldAsVacant = 'N' THEN REPLACE(h.SoldAsVacant,'N','No') 
							ELSE h.SoldAsVacant
							END AS Sold_As_Vacant
	FROM Tutorial_Project.dbo.Housing_Data AS h

	ALTER TABLE Tutorial_Project.dbo.Housing_Data
	ADD Sold_As_Vacant nvarchar(255)

	UPDATE Tutorial_Project.dbo.Housing_Data
	SET Sold_As_Vacant = CASE WHEN SoldAsVacant = 'Y' THEN REPLACE(SoldAsVacant,'Y','Yes')
						  WHEN SoldAsVacant = 'N' THEN REPLACE(SoldAsVacant,'N','No') 
						  ELSE SoldAsVacant
						  END

  --Just to check that all the records have been changed
	SELECT DISTINCT(h.Sold_As_Vacant)
	FROM Tutorial_Project.dbo.Housing_Data AS h


--7)QUERY TO REMOVE DUPLICATES ROWS
WITH RowNum AS (SELECT *, ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference				--To find out the duplicate rows
ORDER BY UniqueID) AS row_num
FROM Tutorial_Project.dbo.Housing_Data)
SELECT * 
FROM RowNum
WHERE row_num > 1
ORDER BY ParcelID

WITH RowNum AS (SELECT *, ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference				--To delete the duplicate rows
ORDER BY UniqueID) AS row_num
FROM Tutorial_Project.dbo.Housing_Data)
DELETE
FROM RowNum
WHERE row_num > 1
ORDER BY ParcelID


--8)QUERY TO DELETE NOT SO USEFUL COLUMNS
ALTER TABLE Tutorial_Project.dbo.Housing_Data
DROP COLUMN PropertyAddress, SoldAsVacant, OwnerAddress, TaxDistrict, Bedrooms, FullBath, HalfBath