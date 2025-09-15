-- CREATING DATABASE

CREATE SCHEMA Nashville;

-- USING DATABASE 

USE  Nashville;

-- CREATING TABLE 

CREATE TABLE NashvilleHousing (
    UniqueID INT,
    ParcelID VARCHAR(50),
    LandUse VARCHAR(100),
    PropertyAddress VARCHAR(255),
    SaleDate VARCHAR(50),
    SalePrice DECIMAL(15,2),
    LegalReference VARCHAR(100),
    SoldAsVacant VARCHAR(10),
    OwnerName VARCHAR(255),
    OwnerAddress VARCHAR(255),
    Acreage DECIMAL(10,2),
    TaxDistrict VARCHAR(100),
    LandValue DECIMAL(15,2),
    BuildingValue DECIMAL(15,2),
    TotalValue DECIMAL(15,2),
    YearBuilt INT,
    Bedrooms INT,
    FullBath INT,
    HalfBath INT
);

-- LOADING DATA INFILE

-- SHOW VARIABLES LIKE 'secure_file_priv';
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/NashvilleHousingData.csv'
INTO TABLE NashvilleHousing
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    @UniqueID,
    @ParcelID,
    @LandUse,
    @PropertyAddress,
    @SaleDate,
    @SalePrice,
    @LegalReference,
    @SoldAsVacant,
    @OwnerName,
    @OwnerAddress,
    @Acreage,
    @TaxDistrict,
    @LandValue,
    @BuildingValue,
    @TotalValue,
    @YearBuilt,
    @Bedrooms,
    @FullBath,
    @HalfBath
)
SET
    UniqueID       = NULLIF(@UniqueID, ''),
    ParcelID       = NULLIF(@ParcelID, ''),
    LandUse        = NULLIF(@LandUse, ''),
    PropertyAddress= NULLIF(@PropertyAddress, ''),
    SaleDate       = NULLIF(@SaleDate, ''),
    SalePrice      = NULLIF(@SalePrice, ''),
    LegalReference = NULLIF(@LegalReference, ''),
    SoldAsVacant   = NULLIF(@SoldAsVacant, ''),
    OwnerName      = NULLIF(@OwnerName, ''),
    OwnerAddress   = NULLIF(@OwnerAddress, ''),
    Acreage        = NULLIF(@Acreage, ''),
    TaxDistrict    = NULLIF(@TaxDistrict, ''),
    LandValue      = NULLIF(@LandValue, ''),
    BuildingValue  = NULLIF(@BuildingValue, ''),
    TotalValue     = NULLIF(@TotalValue, ''),
    YearBuilt      = NULLIF(@YearBuilt, ''),
    Bedrooms       = NULLIF(@Bedrooms, ''),
    FullBath       = NULLIF(@FullBath, ''),
    HalfBath       = NULLIF(@HalfBath, '');
    
SELECT COUNT(*) FROM nashvillehousing;

-- FIXING DATE FORMAT

UPDATE nashvillehousing SET SaleDate = str_to_date(SaleDate, '%m/%d/%Y');
-- ALTER TABLE nashvillehousing MODIFY SaleDate DATE;

-- CHECKING AND REPLACING NULLS WITH APPROPRIATE VALUES 

SELECT PropertyAddress
FROM nashvillehousing
WHERE PropertyAddress is null;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM nashvillehousing a
     join nashvillehousing b
     on a.ParcelID = b.ParcelID
WHERE a.UniqueID <> b.UniqueID AND a.PropertyAddress is null;

UPDATE nashvillehousing a
       join nashvillehousing b
       on a.ParcelID = b.ParcelID
SET a.PropertyAddress = b.PropertyAddress
WHERE a.UniqueID <> b.UniqueID AND a.PropertyAddress is null;
     
SELECT a.PropertyAddress, a.OwnerName, b.PropertyAddress, b.OwnerName 
FROM nashvillehousing a
	 join nashvillehousing b
     on a.PropertyAddress = b.PropertyAddress
WHERE a.UniqueID <> b.UniqueID AND a.OwnerName is null;

UPDATE nashvillehousing SET OwnerName = 'Confidential'
WHERE OwnerName is null
limit 60000;

select count(UniqueID) FROM nashvillehousing;

-- DIVIDING ADDRESS INTO MULTIPLE FIELDS - Address, City & State

SELECT SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) -1) as PropertySplitAddress,
	   SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) +1, length(PropertyAddress)) as PropertySplitCity
FROM nashvillehousing;

SELECT substring_index(OwnerAddress, ',' , 1) as OwnerSplitAddress,
       substring_index(substring_index(OwnerAddress, ',' , 2), ',', -1) as OwnerSplitCity,
	   substring_index(substring_index(OwnerAddress, ',' , 3), ',', -1) as OwnerSplitState
FROM nashvillehousing;
-- SELECT PARSENAME(REPLACE(OwnerAddress,',','.'), 3) as Address FROM nashvillehousing; -- NOT WORKING IN MYSQL WORKBENCH

ALTER TABLE nashvillehousing ADD COLUMN PropertySplitAddress VARCHAR(150),
							 ADD COLUMN PropertySplitCity VARCHAR(150),
							 ADD COLUMN OwnerSplitAddress VARCHAR(150),
							 ADD COLUMN OwnerSplitCity VARCHAR(150),
							 ADD COLUMN OwnerSplitState VARCHAR(150);
                             
UPDATE nashvillehousing SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) -1);

UPDATE nashvillehousing SET PropertySplitCity = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) +1, length(PropertyAddress));

UPDATE nashvillehousing SET OwnerSplitAddress = substring_index(OwnerAddress, ',' , 1);

UPDATE nashvillehousing SET OwnerSplitCity = substring_index(substring_index(OwnerAddress, ',' , 2), ',', -1);

UPDATE nashvillehousing SET OwnerSplitState = substring_index(substring_index(OwnerAddress, ',' , 3), ',', -1);

SELECT *
FROM nashvillehousing;

-- CHANGING 'Y' and 'N' to 'Yes' and 'No' in SoldAsVacant COLUMN

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM nashvillehousing
GROUP BY SoldAsVacant
ORDER BY COUNT(SoldAsVacant);

/*SELECT SoldAsVacant, CASE 
						  WHEN SoldAsVacant = 'Y' THEN 'Yes'
                          WHEN SoldAsVacant = 'N' THEN 'No'
                          ELSE SoldAsVacant
					 END as SolidVacantUpdated
FROM nashvillehousing; 

UPDATE nashvillehousing SET SoldAsVacant = CASE 
						  WHEN SoldAsVacant = 'Y' THEN 'Yes'
                          WHEN SoldAsVacant = 'N' THEN 'No'
                          ELSE SoldAsVacant
					    END;*/

UPDATE nashvillehousing SET SoldAsVacant = 'No'
WHERE SoldAsVacant = 'N';

UPDATE nashvillehousing SET SoldAsVacant = 'Yes'
WHERE SoldAsVacant = 'Y';

-- REMOVING DUPLICATE RECORDS

SELECT ParcelID, LandUse, PropertyAddress, LegalReference, OwnerName, SalePrice, SaleDate, TaxDistrict, Acreage, COUNT(*)
FROM nashvillehousing
GROUP BY ParcelID, LandUse, PropertyAddress, LegalReference, OwnerName, SalePrice, SaleDate, TaxDistrict, Acreage
HAVING COUNT(*)>1;
					
WITH RowNumCTE AS (SELECT *, ROW_NUMBER() OVER(PARTITION BY ParcelID,
                                         LandUse,
                                         PropertyAddress,
                                         LegalReference,
                                         OwnerName,
                                         SalePrice,
                                         SaleDate,
                                         TaxDistrict,
                                         Acreage
									  -- ORDER BY ParcelID
				                               ) AS row_num
FROM nashvillehousing)
DELETE FROM nashvillehousing
WHERE ParcelID IN ( SELECT ParcelID 
                    FROM RowNumCTE
                    WHERE row_num > 1);
                    
-- REMOVING UNWANTED COLUMNS

ALTER TABLE nashvillehousing DROP COLUMN PropertyAddress,
						     DROP COLUMN OwnerAddress;

