# dissertation-15011617
Github Repository for BSc Computing (Hons) Dissertation 

SIMD Map for Multiple Years
The SIMD Map for Multiple Years is an interactive choropleth map created using R.

Getting Started
These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.   Guidance on how to use and access the map online as an end user can be found in the user guide in my GitHub repository.

Prerequisites
For the development and execution of the map code, I recommend the RStudio graphical user interface.  RStudio can be downloaded for free here.  
The following R libraries are required for the execution of the source code – SPARQL, dplyr, readxl, leaflet, rgdal.  If you do not have these libraries already installed, they should be imported by following these steps:

1.	Run RStudio.
2.	Click on the Packages tab in the bottom right section and click on install.  The following dialog box will appear:
3.	In the Install Packages dialog, type the package name you want to install under the Packages field and then click install. This will install the package you searched for or give you a list of matching packages based on your typed text.
 
Source Code
The source code for the map can be found in my GitHub repository here.  The filename is MapNew.R and should be downloaded to your preferred local drive.
 
Data Files
Historical data for the SIMD and profile information are stored in various Excel worksheets as per the graphic below.  These should also be stored in your preferred local drive. 
The source code for the map will also have to be amended to reflect your preferred file location.
  
Shapefiles
The Local Authority District Shapefile is downloaded during execution of the main map code. Once again, the location of the unzipped file should be amended to reflect your file location.
  
Deployment
To deploy the map to the web, execute the code within RStudio by opening the MapNew.R file, using Ctl-A to highlight the code and selecting run.  Upon successful execution the plot will be rendered in the bottom right hand window as per the example below:
To publish the map to the map, select Publish from the plot window, then Publish to RPubs.  Note: you will have to register with RPubs in order to use this free service.  The map will then be deployed to the Web.

Built With
The map was designed in R using a variety of libraries: 
•	SPARQL for the ability to convert SPARQL queries to an R dataframe
•	dplyr to transform the data
•	readxl to read in external Excel files
•	leaflet to create the interactive choropleth map
•	rgdal to provide bindings to the geospatial data

Versioning
Github is used for version control.

Authors
Copyright (c) 2020 Jacqueline Macmillan.  I can be contacted at 15011617@uhi.ac.uk

License
This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
You should have received a copy of the GNU General Public License along with this program. If not, see https://www.gnu.org/licenses/.

