
-----DATA CLEANING

/*checking out the Dataset columns and rows*/

select *
from nashvielle_housing;

/* Standardize Date format*/

select SaleDate, CONVERT(DATE, SaleDate)
from nashvielle_housing

alter table nashvielle_housing
add SaleDateconverted DATE;

UPDATE nashvielle_housing
set SaleDateconverted = CONVERT(DATE, SaleDATE)

/*populate property address data*/


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.propertyAddress, b.PropertyAddress)
from nashvielle_housing  as a
join nashvielle_housing as b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.propertyAddress, b.PropertyAddress)

from nashvielle_housing  as a
join nashvielle_housing as b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is null


/* Breaking out Address into individual columns (address, city, state)*/

--Breaking out the property Address
select 
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as address
, SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as city
from nashvielle_housing


   alter table nashvielle_housing
add property_city Nvarchar(225);

UPDATE nashvielle_housing
set property_city = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

-- Breaking out the owner Address
select OwnerAddress
from nashvielle_housing

SELECT 
 PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
 PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
 PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
 FROM nashvielle_housing
 
 alter table nashvielle_housing
add owner_address Nvarchar(225);

UPDATE nashvielle_housing
set owner_address = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

 alter table nashvielle_housing
add owner_city Nvarchar(225);

UPDATE nashvielle_housing
set owner_city = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

 alter table nashvielle_housing
add owner_state Nvarchar(225);

UPDATE nashvielle_housing
set owner_state = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


/* Change Y and N to Yes and No in'Sold as Vacant' field */

update nashvielle_housing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'yes'
                    when SoldAsVacant = 'N' then 'No'
					else SoldAsVacant
					end

-- To check if it actually reflected                 
SELECT DISTINCT SoldAsVacant
from nashvielle_housing

/* Remove Duplicates */

WITH RowNum AS (
select *,
          Row_number() over (
          partition by parcelID,
		               PropertyAddress,
					   SalePrice,
					   SaleDate,
					   LegalReference
					   ORDER BY 
					   UniqueID
					   ) row_num
from nashvielle_housing
)
delete
from RowNum
where row_num >1

/* Delete unused Columns */

select *
from nashvielle_housing
	
alter table nashvielle_housing
drop column SaleDate, OwnerAddress, TaxDistrict, PropertyAddress



