resource "aws_lexv2models_slot_type" "spending_category_type" {
  name         = "SpendingCategoryType"
  bot_id       = aws_lexv2models_bot.finance_assistant.id
  bot_version  = "DRAFT"
  locale_id    = "en_US"
  description  = "Categories of spending"

  value_selection_setting {
    resolution_strategy = "TopResolution"
  }

  slot_type_values {
    sample_value { value = "INCOME_DIVIDENDS" }
    synonyms { value = "dividends" }
    synonyms { value = "income dividends" }
  }

  slot_type_values {
    sample_value { value = "INCOME_INTEREST_EARNED" }
    synonyms { value = "income interest earned" }
    synonyms { value = "interest earned" }
  }

  slot_type_values {
    sample_value { value = "INCOME_RETIREMENT_PENSION" }
    synonyms { value = "income retirement pension" }
    synonyms { value = "retirement pension" }
  }

  slot_type_values {
    sample_value { value = "INCOME_TAX_REFUND" }
    synonyms { value = "income tax refund" }
    synonyms { value = "tax refund" }
  }

  slot_type_values {
    sample_value { value = "INCOME_UNEMPLOYMENT" }
    synonyms { value = "unemployment" }
    synonyms { value = "income unemployment" }
  }

  slot_type_values {
    sample_value { value = "INCOME_WAGES" }
    synonyms { value = "income wages" }
    synonyms { value = "wages" }
  }

  slot_type_values {
    sample_value { value = "INCOME_OTHER_INCOME" }
    synonyms { value = "income other income" }
    synonyms { value = "other income" }
  }

  slot_type_values {
    sample_value { value = "TRANSFER_IN_CASH_ADVANCES_AND_LOANS" }
    synonyms { value = "in cash advances and loans" }
    synonyms { value = "transfer in cash advances and loans" }
  }

  slot_type_values {
    sample_value { value = "TRANSFER_IN_DEPOSIT" }
    synonyms { value = "transfer in deposit" }
    synonyms { value = "in deposit" }
  }

  slot_type_values {
    sample_value { value = "TRANSFER_IN_INVESTMENT_AND_RETIREMENT_FUNDS" }
    synonyms { value = "in investment and retirement funds" }
    synonyms { value = "transfer in investment and retirement funds" }
  }

  slot_type_values {
    sample_value { value = "TRANSFER_IN_SAVINGS" }
    synonyms { value = "in savings" }
    synonyms { value = "transfer in savings" }
  }

  slot_type_values {
    sample_value { value = "TRANSFER_IN_ACCOUNT_TRANSFER" }
    synonyms { value = "in account transfer" }
    synonyms { value = "transfer in account transfer" }
  }

  slot_type_values {
    sample_value { value = "TRANSFER_IN_OTHER_TRANSFER_IN" }
    synonyms { value = "transfer in other transfer in" }
    synonyms { value = "in other transfer in" }
  }

  slot_type_values {
    sample_value { value = "TRANSFER_OUT_INVESTMENT_AND_RETIREMENT_FUNDS" }
    synonyms { value = "transfer out investment and retirement funds" }
    synonyms { value = "out investment and retirement funds" }
  }

  slot_type_values {
    sample_value { value = "TRANSFER_OUT_SAVINGS" }
    synonyms { value = "out savings" }
    synonyms { value = "transfer out savings" }
  }

  slot_type_values {
    sample_value { value = "TRANSFER_OUT_WITHDRAWAL" }
    synonyms { value = "out withdrawal" }
    synonyms { value = "transfer out withdrawal" }
  }

  slot_type_values {
    sample_value { value = "TRANSFER_OUT_ACCOUNT_TRANSFER" }
    synonyms { value = "transfer out account transfer" }
    synonyms { value = "out account transfer" }
  }

  slot_type_values {
    sample_value { value = "TRANSFER_OUT_OTHER_TRANSFER_OUT" }
    synonyms { value = "transfer out other transfer out" }
    synonyms { value = "out other transfer out" }
  }

  slot_type_values {
    sample_value { value = "LOAN_PAYMENTS_CAR_PAYMENT" }
    synonyms { value = "loan payments car payment" }
    synonyms { value = "payments car payment" }
  }

  slot_type_values {
    sample_value { value = "LOAN_PAYMENTS_CREDIT_CARD_PAYMENT" }
    synonyms { value = "loan payments credit card payment" }
    synonyms { value = "payments credit card payment" }
  }

  slot_type_values {
    sample_value { value = "LOAN_PAYMENTS_PERSONAL_LOAN_PAYMENT" }
    synonyms { value = "payments personal loan payment" }
    synonyms { value = "loan payments personal loan payment" }
  }

  slot_type_values {
    sample_value { value = "LOAN_PAYMENTS_MORTGAGE_PAYMENT" }
    synonyms { value = "payments mortgage payment" }
    synonyms { value = "loan payments mortgage payment" }
  }

  slot_type_values {
    sample_value { value = "LOAN_PAYMENTS_STUDENT_LOAN_PAYMENT" }
    synonyms { value = "payments student loan payment" }
    synonyms { value = "loan payments student loan payment" }
  }

  slot_type_values {
    sample_value { value = "LOAN_PAYMENTS_OTHER_PAYMENT" }
    synonyms { value = "loan payments other payment" }
    synonyms { value = "payments other payment" }
  }

  slot_type_values {
    sample_value { value = "BANK_FEES_ATM_FEES" }
    synonyms { value = "bank fees atm fees" }
    synonyms { value = "fees atm fees" }
  }

  slot_type_values {
    sample_value { value = "BANK_FEES_FOREIGN_TRANSACTION_FEES" }
    synonyms { value = "bank fees foreign transaction fees" }
    synonyms { value = "fees foreign transaction fees" }
  }

  slot_type_values {
    sample_value { value = "BANK_FEES_INSUFFICIENT_FUNDS" }
    synonyms { value = "bank fees insufficient funds" }
    synonyms { value = "fees insufficient funds" }
  }

  slot_type_values {
    sample_value { value = "BANK_FEES_INTEREST_CHARGE" }
    synonyms { value = "bank fees interest charge" }
    synonyms { value = "fees interest charge" }
  }

  slot_type_values {
    sample_value { value = "BANK_FEES_OVERDRAFT_FEES" }
    synonyms { value = "bank fees overdraft fees" }
    synonyms { value = "fees overdraft fees" }
  }

  slot_type_values {
    sample_value { value = "BANK_FEES_OTHER_BANK_FEES" }
    synonyms { value = "bank fees other bank fees" }
    synonyms { value = "fees other bank fees" }
  }

  slot_type_values {
    sample_value { value = "ENTERTAINMENT_CASINOS_AND_GAMBLING" }
    synonyms { value = "casinos and gambling" }
    synonyms { value = "entertainment casinos and gambling" }
  }

  slot_type_values {
    sample_value { value = "ENTERTAINMENT_MUSIC_AND_AUDIO" }
    synonyms { value = "entertainment music and audio" }
    synonyms { value = "music and audio" }
  }

  slot_type_values {
    sample_value { value = "ENTERTAINMENT_SPORTING_EVENTS_AMUSEMENT_PARKS_AND_MUSEUMS" }
    synonyms { value = "entertainment sporting events amusement parks and museums" }
    synonyms { value = "sporting events amusement parks and museums" }
  }

  slot_type_values {
    sample_value { value = "ENTERTAINMENT_TV_AND_MOVIES" }
    synonyms { value = "entertainment tv and movies" }
    synonyms { value = "tv and movies" }
  }

  slot_type_values {
    sample_value { value = "ENTERTAINMENT_VIDEO_GAMES" }
    synonyms { value = "video games" }
    synonyms { value = "entertainment video games" }
  }

  slot_type_values {
    sample_value { value = "ENTERTAINMENT_OTHER_ENTERTAINMENT" }
    synonyms { value = "entertainment other entertainment" }
    synonyms { value = "other entertainment" }
  }

  slot_type_values {
    sample_value { value = "FOOD_AND_DRINK_BEER_WINE_AND_LIQUOR" }
    synonyms { value = "food and drink beer wine and liquor" }
    synonyms { value = "and drink beer wine and liquor" }
  }

  slot_type_values {
    sample_value { value = "FOOD_AND_DRINK_COFFEE" }
    synonyms { value = "and drink coffee" }
    synonyms { value = "food and drink coffee" }
  }

  slot_type_values {
    sample_value { value = "FOOD_AND_DRINK_FAST_FOOD" }
    synonyms { value = "and drink fast food" }
    synonyms { value = "food and drink fast food" }
  }

  slot_type_values {
    sample_value { value = "FOOD_AND_DRINK_GROCERIES" }
    synonyms { value = "food and drink groceries" }
    synonyms { value = "and drink groceries" }
    synonyms { value = "groceries" }
    synonyms { value = "grocery" }
    synonyms { value = "supermarket" }
  }

  slot_type_values {
    sample_value { value = "FOOD_AND_DRINK_RESTAURANT" }
    synonyms { value = "food and drink restaurant" }
    synonyms { value = "and drink restaurant" }
    synonyms { value = "dining" }
    synonyms { value = "restaurants" }
    synonyms { value = "eating out" }
  }

  slot_type_values {
    sample_value { value = "FOOD_AND_DRINK_VENDING_MACHINES" }
    synonyms { value = "and drink vending machines" }
    synonyms { value = "food and drink vending machines" }
  }

  slot_type_values {
    sample_value { value = "FOOD_AND_DRINK_OTHER_FOOD_AND_DRINK" }
    synonyms { value = "food and drink other food and drink" }
    synonyms { value = "and drink other food and drink" }
  }

  slot_type_values {
    sample_value { value = "GENERAL_MERCHANDISE_BOOKSTORES_AND_NEWSSTANDS" }
    synonyms { value = "merchandise bookstores and newsstands" }
    synonyms { value = "general merchandise bookstores and newsstands" }
  }

  slot_type_values {
    sample_value { value = "GENERAL_MERCHANDISE_CLOTHING_AND_ACCESSORIES" }
    synonyms { value = "general merchandise clothing and accessories" }
    synonyms { value = "merchandise clothing and accessories" }
    synonyms { value = "clothing" }
    synonyms { value = "clothes" }
  }

  slot_type_values {
    sample_value { value = "GENERAL_MERCHANDISE_CONVENIENCE_STORES" }
    synonyms { value = "general merchandise convenience stores" }
    synonyms { value = "merchandise convenience stores" }
  }

  slot_type_values {
    sample_value { value = "GENERAL_MERCHANDISE_DEPARTMENT_STORES" }
    synonyms { value = "general merchandise department stores" }
    synonyms { value = "merchandise department stores" }
  }

  slot_type_values {
    sample_value { value = "GENERAL_MERCHANDISE_DISCOUNT_STORES" }
    synonyms { value = "merchandise discount stores" }
    synonyms { value = "general merchandise discount stores" }
  }

  slot_type_values {
    sample_value { value = "GENERAL_MERCHANDISE_ELECTRONICS" }
    synonyms { value = "merchandise electronics" }
    synonyms { value = "general merchandise electronics" }
    synonyms { value = "electronics" }
  }

  slot_type_values {
    sample_value { value = "GENERAL_MERCHANDISE_GIFTS_AND_NOVELTIES" }
    synonyms { value = "merchandise gifts and novelties" }
    synonyms { value = "general merchandise gifts and novelties" }
  }

  slot_type_values {
    sample_value { value = "GENERAL_MERCHANDISE_OFFICE_SUPPLIES" }
    synonyms { value = "merchandise office supplies" }
    synonyms { value = "general merchandise office supplies" }
  }

  slot_type_values {
    sample_value { value = "GENERAL_MERCHANDISE_ONLINE_MARKETPLACES" }
    synonyms { value = "general merchandise online marketplaces" }
    synonyms { value = "merchandise online marketplaces" }
  }

  slot_type_values {
    sample_value { value = "GENERAL_MERCHANDISE_PET_SUPPLIES" }
    synonyms { value = "general merchandise pet supplies" }
    synonyms { value = "merchandise pet supplies" }
  }

  slot_type_values {
    sample_value { value = "GENERAL_MERCHANDISE_SPORTING_GOODS" }
    synonyms { value = "merchandise sporting goods" }
    synonyms { value = "general merchandise sporting goods" }
  }

  slot_type_values {
    sample_value { value = "GENERAL_MERCHANDISE_SUPERSTORES" }
    synonyms { value = "merchandise superstores" }
    synonyms { value = "general merchandise superstores" }
  }

  slot_type_values {
    sample_value { value = "GENERAL_MERCHANDISE_TOBACCO_AND_VAPE" }
    synonyms { value = "merchandise tobacco and vape" }
    synonyms { value = "general merchandise tobacco and vape" }
  }

  slot_type_values {
    sample_value { value = "GENERAL_MERCHANDISE_OTHER_GENERAL_MERCHANDISE" }
    synonyms { value = "merchandise other general merchandise" }
    synonyms { value = "general merchandise other general merchandise" }
    synonyms { value = "shopping" }
    synonyms { value = "retail" }
    synonyms { value = "purchases" }
  }

  slot_type_values {
    sample_value { value = "HOME_IMPROVEMENT_FURNITURE" }
    synonyms { value = "improvement furniture" }
    synonyms { value = "home improvement furniture" }
  }

  slot_type_values {
    sample_value { value = "HOME_IMPROVEMENT_HARDWARE" }
    synonyms { value = "improvement hardware" }
    synonyms { value = "home improvement hardware" }
  }

  slot_type_values {
    sample_value { value = "HOME_IMPROVEMENT_REPAIR_AND_MAINTENANCE" }
    synonyms { value = "improvement repair and maintenance" }
    synonyms { value = "home improvement repair and maintenance" }
  }

  slot_type_values {
    sample_value { value = "HOME_IMPROVEMENT_SECURITY" }
    synonyms { value = "improvement security" }
    synonyms { value = "home improvement security" }
  }

  slot_type_values {
    sample_value { value = "HOME_IMPROVEMENT_OTHER_HOME_IMPROVEMENT" }
    synonyms { value = "improvement other home improvement" }
    synonyms { value = "home improvement other home improvement" }
  }

  slot_type_values {
    sample_value { value = "MEDICAL_DENTAL_CARE" }
    synonyms { value = "dental care" }
    synonyms { value = "medical dental care" }
  }

  slot_type_values {
    sample_value { value = "MEDICAL_EYE_CARE" }
    synonyms { value = "eye care" }
    synonyms { value = "medical eye care" }
  }

  slot_type_values {
    sample_value { value = "MEDICAL_NURSING_CARE" }
    synonyms { value = "medical nursing care" }
    synonyms { value = "nursing care" }
  }

  slot_type_values {
    sample_value { value = "MEDICAL_PHARMACIES_AND_SUPPLEMENTS" }
    synonyms { value = "pharmacies and supplements" }
    synonyms { value = "medical pharmacies and supplements" }
  }

  slot_type_values {
    sample_value { value = "MEDICAL_PRIMARY_CARE" }
    synonyms { value = "medical primary care" }
    synonyms { value = "primary care" }
  }

  slot_type_values {
    sample_value { value = "MEDICAL_VETERINARY_SERVICES" }
    synonyms { value = "veterinary services" }
    synonyms { value = "medical veterinary services" }
  }

  slot_type_values {
    sample_value { value = "MEDICAL_OTHER_MEDICAL" }
    synonyms { value = "other medical" }
    synonyms { value = "medical other medical" }
  }

  slot_type_values {
    sample_value { value = "PERSONAL_CARE_GYMS_AND_FITNESS_CENTERS" }
    synonyms { value = "personal care gyms and fitness centers" }
    synonyms { value = "care gyms and fitness centers" }
  }

  slot_type_values {
    sample_value { value = "PERSONAL_CARE_HAIR_AND_BEAUTY" }
    synonyms { value = "personal care hair and beauty" }
    synonyms { value = "care hair and beauty" }
  }

  slot_type_values {
    sample_value { value = "PERSONAL_CARE_LAUNDRY_AND_DRY_CLEANING" }
    synonyms { value = "personal care laundry and dry cleaning" }
    synonyms { value = "care laundry and dry cleaning" }
  }

  slot_type_values {
    sample_value { value = "PERSONAL_CARE_OTHER_PERSONAL_CARE" }
    synonyms { value = "care other personal care" }
    synonyms { value = "personal care other personal care" }
  }

  slot_type_values {
    sample_value { value = "GENERAL_SERVICES_ACCOUNTING_AND_FINANCIAL_PLANNING" }
    synonyms { value = "general services accounting and financial planning" }
    synonyms { value = "services accounting and financial planning" }
  }

  slot_type_values {
    sample_value { value = "GENERAL_SERVICES_AUTOMOTIVE" }
    synonyms { value = "general services automotive" }
    synonyms { value = "services automotive" }
  }

  slot_type_values {
    sample_value { value = "GENERAL_SERVICES_CHILDCARE" }
    synonyms { value = "general services childcare" }
    synonyms { value = "services childcare" }
  }

  slot_type_values {
    sample_value { value = "GENERAL_SERVICES_CONSULTING_AND_LEGAL" }
    synonyms { value = "general services consulting and legal" }
    synonyms { value = "services consulting and legal" }
  }

  slot_type_values {
    sample_value { value = "GENERAL_SERVICES_EDUCATION" }
    synonyms { value = "services education" }
    synonyms { value = "general services education" }
  }

  slot_type_values {
    sample_value { value = "GENERAL_SERVICES_INSURANCE" }
    synonyms { value = "services insurance" }
    synonyms { value = "general services insurance" }
  }

  slot_type_values {
    sample_value { value = "GENERAL_SERVICES_POSTAGE_AND_SHIPPING" }
    synonyms { value = "services postage and shipping" }
    synonyms { value = "general services postage and shipping" }
  }

  slot_type_values {
    sample_value { value = "GENERAL_SERVICES_STORAGE" }
    synonyms { value = "general services storage" }
    synonyms { value = "services storage" }
  }

  slot_type_values {
    sample_value { value = "GENERAL_SERVICES_OTHER_GENERAL_SERVICES" }
    synonyms { value = "general services other general services" }
    synonyms { value = "services other general services" }
  }

  slot_type_values {
    sample_value { value = "GOVERNMENT_AND_NON_PROFIT_DONATIONS" }
    synonyms { value = "government and non profit donations" }
    synonyms { value = "and non profit donations" }
  }

  slot_type_values {
    sample_value { value = "GOVERNMENT_AND_NON_PROFIT_GOVERNMENT_DEPARTMENTS_AND_AGENCIES" }
    synonyms { value = "and non profit government departments and agencies" }
    synonyms { value = "government and non profit government departments and agencies" }
  }

  slot_type_values {
    sample_value { value = "GOVERNMENT_AND_NON_PROFIT_TAX_PAYMENT" }
    synonyms { value = "and non profit tax payment" }
    synonyms { value = "government and non profit tax payment" }
  }

  slot_type_values {
    sample_value { value = "GOVERNMENT_AND_NON_PROFIT_OTHER_GOVERNMENT_AND_NON_PROFIT" }
    synonyms { value = "government and non profit other government and non profit" }
    synonyms { value = "and non profit other government and non profit" }
  }

  slot_type_values {
    sample_value { value = "TRANSPORTATION_BIKES_AND_SCOOTERS" }
    synonyms { value = "bikes and scooters" }
    synonyms { value = "transportation bikes and scooters" }
  }

  slot_type_values {
    sample_value { value = "TRANSPORTATION_GAS" }
    synonyms { value = "transportation gas" }
    synonyms { value = "gas" }
  }

  slot_type_values {
    sample_value { value = "TRANSPORTATION_PARKING" }
    synonyms { value = "parking" }
    synonyms { value = "transportation parking" }
  }

  slot_type_values {
    sample_value { value = "TRANSPORTATION_PUBLIC_TRANSIT" }
    synonyms { value = "transportation public transit" }
    synonyms { value = "public transit" }
  }

  slot_type_values {
    sample_value { value = "TRANSPORTATION_TAXIS_AND_RIDE_SHARES" }
    synonyms { value = "taxis and ride shares" }
    synonyms { value = "transportation taxis and ride shares" }
  }

  slot_type_values {
    sample_value { value = "TRANSPORTATION_TOLLS" }
    synonyms { value = "tolls" }
    synonyms { value = "transportation tolls" }
  }

  slot_type_values {
    sample_value { value = "TRANSPORTATION_OTHER_TRANSPORTATION" }
    synonyms { value = "transportation other transportation" }
    synonyms { value = "other transportation" }
    synonyms { value = "transportation" }
    synonyms { value = "transit" }
    synonyms { value = "commute" }
  }

  slot_type_values {
    sample_value { value = "TRAVEL_FLIGHTS" }
    synonyms { value = "travel flights" }
    synonyms { value = "flights" }
  }

  slot_type_values {
    sample_value { value = "TRAVEL_LODGING" }
    synonyms { value = "travel lodging" }
    synonyms { value = "lodging" }
  }

  slot_type_values {
    sample_value { value = "TRAVEL_RENTAL_CARS" }
    synonyms { value = "rental cars" }
    synonyms { value = "travel rental cars" }
  }

  slot_type_values {
    sample_value { value = "TRAVEL_OTHER_TRAVEL" }
    synonyms { value = "travel other travel" }
    synonyms { value = "other travel" }
    synonyms { value = "travel" }
  }

  slot_type_values {
    sample_value { value = "RENT_AND_UTILITIES_GAS_AND_ELECTRICITY" }
    synonyms { value = "rent and utilities gas and electricity" }
    synonyms { value = "and utilities gas and electricity" }
  }

  slot_type_values {
    sample_value { value = "RENT_AND_UTILITIES_INTERNET_AND_CABLE" }
    synonyms { value = "rent and utilities internet and cable" }
    synonyms { value = "and utilities internet and cable" }
  }

  slot_type_values {
    sample_value { value = "RENT_AND_UTILITIES_RENT" }
    synonyms { value = "rent and utilities rent" }
    synonyms { value = "and utilities rent" }
  }

  slot_type_values {
    sample_value { value = "RENT_AND_UTILITIES_SEWAGE_AND_WASTE_MANAGEMENT" }
    synonyms { value = "and utilities sewage and waste management" }
    synonyms { value = "rent and utilities sewage and waste management" }
  }

  slot_type_values {
    sample_value { value = "RENT_AND_UTILITIES_TELEPHONE" }
    synonyms { value = "and utilities telephone" }
    synonyms { value = "rent and utilities telephone" }
  }

  slot_type_values {
    sample_value { value = "RENT_AND_UTILITIES_WATER" }
    synonyms { value = "rent and utilities water" }
    synonyms { value = "and utilities water" }
  }

  slot_type_values {
    sample_value { value = "RENT_AND_UTILITIES_OTHER_UTILITIES" }
    synonyms { value = "and utilities other utilities" }
    synonyms { value = "rent and utilities other utilities" }
    synonyms { value = "utilities" }
    synonyms { value = "bills" }
    synonyms { value = "electricity" }
    synonyms { value = "water" }
  }

  depends_on = [
    aws_lexv2models_bot_locale.english_locale
  ]
}