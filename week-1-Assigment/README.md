# Week 1 Data Engineering Assignment

## Summary
In this assignment, I worked with a Shopping dataset from Kaggle using Python and Pandas. The goal of this task was to learn how to load, explore, clean, and perform basic operations on a real-world dataset. The dataset contained 1,000 product listings with 24 columns covering product details like title, price, rating, discount, seller information, customer reviews, and category.

## Load a CSV Dataset into a Pandas DataFrame
I loaded the CSV file into a Pandas DataFrame using the `read_csv()` function. After loading, I verified that the data was imported correctly by viewing a few sample rows.

##  Explore the Dataset
I explored the dataset using various Pandas functions such as `head()`, `tail()`, `sample()`, `shape`, `columns`, `dtypes`, `info()`, and `describe()`.

From my exploration, I observed that the dataset has 1,000 rows and 24 columns. The data includes product information such as title, product description, rating, ratings count, initial price, final price, discount, category, seller name, customer reviews, and more. I also used `describe(include='object')` to analyze the categorical columns and found that the dataset has 97 unique product categories, with "tops" being the most frequent category.

##Handle Missing Values
After exploring the dataset, I checked for missing values using `isnull().sum()`.

I found missing values in the following columns: `discount` (12.1%), `what_customers_said` (57.3%), `seller_name` (30.1%), `videos` (78.1%), `seller_information` (30.1%), and `variations` (56.2%).

Rather than dropping all the rows with missing data, I handled each column with a different strategy based on the nature of the data. The `discount` column was filled with the median value. The `seller_name` column was filled with "Unknown Seller" and `seller_information` was filled with "Information not Found". For the `what_customers_said` column, since it contains important customer feedback, I created an indicator flag column called `has_customer_reviews` to track which products originally had reviews, and then filled the null values with an empty list "[]" to preserve the structure. The `videos` and `variations` columns were dropped entirely because they had very high null percentages and did not contribute to the core analysis.

After these operations, the dataset had zero missing values.

##  Perform Basic Operations
I performed several basic operations on the cleaned dataset.

First, I selected relevant columns like title, category, initial price, and final price for pricing analysis. Then I filtered the data to show only products from the "backpacks" category and found 4 products. I also filtered for highly rated products with a rating greater than 4.5 and for products with discounts greater than 60%.

Additionally, I used `.loc[]` to extract the title and discount for all products where the discount is greater than 50%. I also sorted the dataset by rating in descending order to see the top-rated products and used `value_counts()` to see the distribution of products across categories.

## Remove Duplicates
To ensure data quality, I checked the dataset for duplicate records using the `duplicated()` function. I checked for both full-row duplicates and duplicate `product_id` values.

The dataset did not contain any duplicate entries. As a result, no rows were removed and the dataset size remained unchanged. This confirmed that the data was already clean in terms of duplicates.

## Create a Derived Column
The assignment required creating a derived column using the formula: `total_amount = price × quantity`.

Since the dataset did not contain a `quantity` column (it is a product catalog, not a transactions dataset), I assumed a quantity of 1 for each product. Before creating the derived column, I first cleaned the `final_price` column by removing the rupee symbol (₹), commas, and quotes using regex, and then converted it from a string to a float value using `pd.to_numeric()`.

Using the cleaned `final_price` and the assumed `quantity`, I created a new column called `total_amount`. This step demonstrated how new features can be derived from existing data.

##  Save the Cleaned Dataset
After completing all cleaning and transformation tasks, I saved the final dataset as a new CSV file named `cleaned_data.csv` using `to_csv()`.

The exported file contains all the original columns along with the newly created columns: `has_customer_reviews`, `quantity`, and `total_amount`. The final cleaned dataset has 1,000 rows and 25 columns.

## Conclusion
Through this assignment, I learned how to work with real-world datasets using Pandas. I gained practical experience in loading data, exploring dataset structures, handling missing values with different strategies, converting data types, filtering and sorting records, checking for duplicates, creating derived features, and exporting cleaned data. These are fundamental steps in data preprocessing and data engineering workflows.
