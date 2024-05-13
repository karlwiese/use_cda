DROP TABLE IF EXISTS hcp
;
CREATE TABLE hcp (
    veevaid VARCHAR(25),
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    middle_name VARCHAR(50),
    prefix VARCHAR(10),
    suffix VARCHAR(10),
    "language" CHAR(2),
    email VARCHAR(80),
    mobile_phone VARCHAR(40),
    office_phone VARCHAR(40),
    fax VARCHAR(40),
    country CHAR(2),
    "state" VARCHAR(6),
    city VARCHAR(40),
    postal_code VARCHAR(20),
    hcp_type CHAR(4),
    nhid VARCHAR(40),
    spec_1 VARCHAR(4),
    all_spec VARCHAR(4)[],
    spec_group_1 CHAR(2),
    all_spec_group CHAR(2)[],
    prescriber BOOLEAN,
    degree_1 VARCHAR(4),
    all_degree VARCHAR(4)[],
    status VARCHAR(4),
    "level" SMALLINT,
    adopter_type VARCHAR(4),
    kol BOOLEAN,
    investigator BOOLEAN,
    speaker BOOLEAN,
    target BOOLEAN
)
;
COMMENT ON TABLE hcp IS 'Label: HCP, Description: Information about a Healthcare Professional (HCP), broadly defined as an individual who plays a role in the development, testing, manufacturing, or commercialization of life science products, or in the delivery and administration of healthcare services related to these products.'
;
COMMENT ON COLUMN hcp.veevaid IS 'Label: Veeva ID, Description: Global identifier from Veeva data products'
;
COMMENT ON COLUMN hcp.first_name IS 'Label: First Name, Description: Given name as officially recorded in professional or legal documents.'
;
COMMENT ON COLUMN hcp.last_name IS 'Label: Last Name, Description: Family or surname as officially recorded in professional or legal documents.'
;
COMMENT ON COLUMN hcp.middle_name IS 'Label: Middle Name, Description: Secondary given name or initial as officially recorded in professional or legal documents.'
;
COMMENT ON COLUMN hcp.prefix IS 'Label: Prefix, Description: Salutation or title used before a person''s name, such as Mr., Mrs., Dr., etc.'
;
COMMENT ON COLUMN hcp.suffix IS 'Label: Suffix, Description: Includes professional credentials or generational titles such as I, II, III, IV, but excludes medical degrees.'
;
COMMENT ON COLUMN hcp.language IS 'Label: Primary Language, Description: Primary spoken and written language., Picklist Items: Language Items'
;
COMMENT ON COLUMN hcp.email IS 'Label: Primary Email, Description: Primary email address., Notes: An email address can be 254 characters in length according to RFCs. However, many common systems can not process email addresses longer than 80. CDA is designed for system interoperability, so it is important to have email addresses that can be used by all systems. In addition, more than 99.9999% of email addresses are less than 80 characters.'
;
COMMENT ON COLUMN hcp.mobile_phone IS 'Label: Mobile Phone, Description: Primary mobile phone number. May include country code including non-alphanumeric characters. e.g. +, -, (, )'
;
COMMENT ON COLUMN hcp.office_phone IS 'Label: Office Phone, Description: Primary office phone number. May include country code including non-alphanumeric characters. e.g. +, -'
;
COMMENT ON COLUMN hcp.fax IS 'Label: Fax, Description: Primary fax. May include country code including non-alphanumeric characters. e.g. +, -'
;
COMMENT ON COLUMN hcp.country IS 'Label: Primary Country, Description: Country from primary address., Picklist Items: Country Items, Notes: Denormed from Primary Address.'
;
COMMENT ON COLUMN hcp.state IS 'Label: Primary State, Description: State, province, or regional area from primary address., Picklist Items: State Items, Notes: Denormed from Primary Address'
;
COMMENT ON COLUMN hcp.city IS 'Label: Primary City, Description: City or municipality from primary address., Notes: Denormed from Primary Address'
;
COMMENT ON COLUMN hcp.postal_code IS 'Label: Primary Postal Code, Description: Postal code from primary address. May include non-alphanumeric characters. e.g. -, Notes: Denormed from Primary Address'
;
COMMENT ON COLUMN hcp.hcp_type IS 'Label: Type, Description: The role an individual plays in the life sciences industry, spanning from the development and commercialization of life science products to their delivery and administration in healthcare settings., Picklist Items: Type Items'
;
COMMENT ON COLUMN hcp.nhid IS 'Label: National Healthcare ID, Description: Unique identifier assigned to healthcare professionals within a country''s healthcare system.'
;
COMMENT ON COLUMN hcp.spec_1 IS 'Label: Primary Speciality, Description: The primary medical field or expertise area to which the healthcare professional belongs. Uses the list of specialties., Picklist Items: Specialty Items'
;
COMMENT ON COLUMN hcp.all_spec IS 'Label: All Specialties, Description: All medical fields and expertise areas to which the healthcare provider belongs. Uses the list of specialties., Picklist Items: Specialty Items, Notes: Always includes spec1'
;
COMMENT ON COLUMN hcp.spec_group_1 IS 'Label: Primary Specialty Group, Description: The primary overarching medical field or expertise area to which the healthcare provider belongs. Uses the list of global specialties., Picklist Items: Specialty Group Items, Notes: Automatically populated based on value in spec1'
;
COMMENT ON COLUMN hcp.all_spec_group IS 'Label: All Specialty Groups, Description: All overarching medical fields and expertise areas to which the healthcare provider belongs. Uses the list of global specialties., Picklist Items: Specialty Group Items, Notes: Automatically populated based on values in allspec'
;
COMMENT ON COLUMN hcp.prescriber IS 'Label: Prescriber, Description: Indicates whether the individual is authorized to prescribe medications.'
;
COMMENT ON COLUMN hcp.degree_1 IS 'Label: Primary Medical Degree, Description: The primary medical qualification or degree obtained., Picklist Items: Medical Degree Items'
;
COMMENT ON COLUMN hcp.all_degree IS 'Label: All Medical Degrees, Description: Additional medical qualification or degree obtained., Picklist Items: Medical Degree Items'
;
COMMENT ON COLUMN hcp.status IS 'Label: Status, Description: Indicates whether the healthcare professional is currently active and working or not., Picklist Items: HCP Status Items'
;
COMMENT ON COLUMN hcp.level IS 'Label: Level, Description: Indicates the level of importance of this individual to the company, where level 5 indicates the highest level of importance. Can be used to drive business rules. For example: You may want to limit personalized promotions to levels 3 and below. You may also require a single relationship owner for level 5., Picklist Items: Level Items'
;
COMMENT ON COLUMN hcp.adopter_type IS 'Label: Adopter Type, Description: A categorization of the individual based on their willingness and speed to adopt new medical technologies, treatments, practices, or products., Picklist Items: Adopter Type Items'
;
COMMENT ON COLUMN hcp.kol IS 'Label: Key Opinion Leader, Description: Recognized as a key opinion leader in the industry.'
;
COMMENT ON COLUMN hcp.investigator IS 'Label: Investigator, Description: Indicates whether the individual is involved in running clinical research studies.'
;
COMMENT ON COLUMN hcp.speaker IS 'Label: Speaker, Description: Indicates whether the individual is engaged in speaking roles at professional gatherings or educational events for the company.'
;
COMMENT ON COLUMN hcp.target IS 'Label: Target, Description: Indicates whether the individual is a target for one or more brands of the company.'
;

DROP TABLE IF EXISTS hcp_segment
;
CREATE TABLE hcp_segment (
    hcp INT,
    "name" VARCHAR(50),
    "source" VARCHAR(50)
)
;
COMMENT ON TABLE hcp_segment IS 'Label: Segment, Description: A grouping of HCPs based on shared characteristics, behaviors, preferences, or needs. Typically used to tailor marketing, sales, and support efforts more effectively, by acknowledging that different groups may require different approaches or products.'
;
COMMENT ON COLUMN hcp_segment.hcp IS 'Label: HCP, Description: HCP that belongs to this segment.'
;
COMMENT ON COLUMN hcp_segment.name IS 'Label: Name, Description: Name of the segment.'
;
COMMENT ON COLUMN hcp_segment.source IS 'Label: Source, Description: Source system the segment was created in.'
;

DROP TABLE IF EXISTS address
;
CREATE TABLE address (
    hcp INT,
    "primary" BOOLEAN,
    street_address_1 VARCHAR(80),
    street_address_2 VARCHAR(100),
    country CHAR(2),
    "state" VARCHAR(6),
    city VARCHAR(40),
    postal_code VARCHAR(20),
    latitude VARCHAR(15),
    longitude VARCHAR(15),
    phone VARCHAR(40),
    fax VARCHAR(40),
    status VARCHAR(4),
    home BOOLEAN,
    business BOOLEAN,
    billing BOOLEAN,
    shipping BOOLEAN,
    sample_shipping BOOLEAN
)
;
COMMENT ON TABLE address IS 'Label: Address, Description: Location information associated with an HCP.'
;
COMMENT ON COLUMN address.hcp IS 'Label: HCP, Description: HCP associated with this address.'
;
COMMENT ON COLUMN address.primary IS 'Label: Primary, Description: Indicates whether this represents the individual''s primary address. Only one address can be marked as Primary.'
;
COMMENT ON COLUMN address.street_address_1 IS 'Label: Street Address 1, Description: Residential or business street address information including house number and street name.'
;
COMMENT ON COLUMN address.street_address_2 IS 'Label: Street Address 2, Description: Additional address details, such as apartment, suite, or building number.'
;
COMMENT ON COLUMN address.country IS 'Label: Country, Description: Name of country., Picklist Items: Country Items'
;
COMMENT ON COLUMN address.state IS 'Label: State, Description: Name of state, province, or regional area., Picklist Items: State Items'
;
COMMENT ON COLUMN address.city IS 'Label: City, Description: Name of city or municipality.'
;
COMMENT ON COLUMN address.postal_code IS 'Label: Postal Code, Description: May include non-alphanumeric characters. e.g. -'
;
COMMENT ON COLUMN address.latitude IS 'Label: Latitude, Description: Geographic coordinate specifying north-south position.'
;
COMMENT ON COLUMN address.longitude IS 'Label: Longitude, Description: Geographic coordinate indicating east-west position.'
;
COMMENT ON COLUMN address.phone IS 'Label: Phone, Description: Phone number. May include country code including non-alphanumeric characters. e.g. +, -'
;
COMMENT ON COLUMN address.fax IS 'Label: Fax, Description: Fax number. May include country code including non-alphanumeric characters. e.g. +, -'
;
COMMENT ON COLUMN address.status IS 'Label: Status, Description: Indicates whether this address is currently usable for contact purposes., Picklist Items: Address Status Items'
;
COMMENT ON COLUMN address.home IS 'Label: Home, Description: Indicates whether this represents a home address.'
;
COMMENT ON COLUMN address.business IS 'Label: Business, Description: Indicates whether this represents a business address.'
;
COMMENT ON COLUMN address.billing IS 'Label: Billing, Description: Indicates whether this represents a billing address.'
;
COMMENT ON COLUMN address.shipping IS 'Label: Shipping, Description: Indicates whether this represents a shipping address.'
;
COMMENT ON COLUMN address.sample_shipping IS 'Label: Sample Shipping, Description: Indicates whether this represents a shipping address that can accept medical shipments.'
;
