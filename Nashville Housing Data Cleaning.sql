/*
Cleaning Data in Sql Queries
*/


select *
from PortfolioProject.dbo.NashvilleHousing


--Standardize Data Format
select SaleDate, convert(date, SaleDate)
from PortfolioProject.dbo.NashvilleHousing
	
update NashvilleHousing
set SaleDate = CONVERT(Date,SaleDate)

alter table NashvilleHousing
add SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted = Convert(Date, SaleDate) 

---------------------------------------------------------------------


-- Popuate Property Address Data
Select *
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID


Select  a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull (a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]


update a
set PropertyAddress =  isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

---------------------------------------------------------------------


--Breaking out address into individual columns (address, city, states)

Select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

select
SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1 , len(PropertyAddress)) as Address

from PortfolioProject.dbo.NashvilleHousing


alter table NashvilleHousing
add PropertySplitAddress Nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress) -1)




alter table NashvilleHousing
add PropertySplitCity Nvarchar(255);

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1 , len(PropertyAddress))


Select 
Parsename (Replace(OwnerAddress, ',', '.'), 1)
, Parsename (Replace(OwnerAddress, ',', '.'), 2)
, Parsename (Replace(OwnerAddress, ',', '.'), 3)
from PortfolioProject.dbo.NashvilleHousing


alter table NashvilleHousing
add OwnerSplitAddress Nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = Parsename (Replace(OwnerAddress, ',', '.'), 1)


alter table NashvilleHousing
add OwnerSplitCity Nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = Parsename (Replace(OwnerAddress, ',', '.'), 2)



alter table NashvilleHousing
add OwnerSplitState Nvarchar(255);

update NashvilleHousing
set OwnerSplitState = Parsename (Replace(OwnerAddress, ',', '.'), 3)

---------------------------------------------------------------------


-- Change Y and N to Yes and No in "Solid as Vacant" field--

Select Distinct(SoldAsVacant), Count (SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, Case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	End
From PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	End

---------------------------------------------------------------------


--Remove Duplicates

with RowNumCTE AS(
Select *,
	row_number()over (
	Partition by ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order by 
					UniqueID
					) row_num

from PortfolioProject.dbo.NashvilleHousing
)

Select *
from RowNumCTE
where row_num > 1
--order by PropertyAddress
---------------------------------------------------------------------


-- Delete Unused Columns

Select *
From PortfolioProject.dbo.NashvilleHousing

Alter Table PortfolioProject.dbo.NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table PortfolioProject.dbo.NashvilleHousing
Drop Column SaleDate
