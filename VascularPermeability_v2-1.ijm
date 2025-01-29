/*
 * Macro Name: VascularPermeability
 * Version: 2.1
 * Author: Lucas Kreiss, Benjamin Schmid
 * Date: 29.01.2025
 * 
 * Description:
 * This Macro quantifies the Vascular Permeability based on 3D image stacks, 
 * from animals where a fluorescent contrast agent was injected. 
 * The user is asked to move a number of round ROIs in the space between micro-vessels
 * the macro then measures the intensity of the fluorescent dye that leaked to 
 * that space ('Intravascular intensity'). A second measurement is performed to measure the 
 * intensity within a larger ring ROI around the first ROI that also contains the vessels ('local intensity')
 * Finally, the 'Relative Vascular Permeability' is calculated as the ratio of Intravascular intensity 
 * to local intensity
 * The Macro was originally developed for data from our custom-built multiphoton
 * endomicroscope, but should also be applicable to similar data from other systems
 * 
 * Input:
 * the user will be asked to choose a directory containing  
 * image data as Bioformats files including Hyperstack with  
 * a stack order of XYCZT

 * 
 * Output:
 * The Macro automatically iterates over all images in a given folder and saves
 * the results from all files in a csv file called 'QuantificationResults.csv'
 * this file will include the follwing:
 * 		Intravascular intensity
 * 		Local intensity 
 *		Relative Vascular Permeability
 * This file will be saved to the same directory that contains the raw data, as selected by the user
 * 
 * Parameters:
 * The user is asked to specify the following parameters:
 * r1 				= default radius of the inner circle ROI for the space between vessels
 * r2 				= default radius of the outer circle ROI for the ring ROI containing the vessels
 * pixel_size 		= default pixel size in micrometer
 * axial_spacing 	= default spacing of axial planes in micrometer
 * 
 */


r1 = 10;
r2 = 2.5 * r1;
nCircles = 5; 

pixel_size = 0.566; // in micro meter
axial_spacing = 3; // in micro meter

function processImage() {
	roiManager("reset");
	Overlay.remove;
	run("Clear Results");
	
	getDimensions(width, height, channels, slices, frames);
	cx = width  / 2;
	cy = height / 2;
	
	makeOval(cx - r2, cy - r2, 2 * r2, 2 * r2);
	Overlay.addSelection();
	makeOval(cx - r1, cy - r1, 2 * r1, 2 * r1);
	Overlay.addSelection();
	Overlay.xor(newArray(0, 1));
	
	for(i = 0; i < nCircles; i++) {
		Roi.move(i * 2 * r2, 0);
		roiManager("add");
	}
	
	Overlay.remove;
	Roi.remove;
	roiManager("deselect");
	roiManager("remove slice info");
	roiManager("show all with labels");
	
	regions = newArray("Z1", "Z2");
	
	for(r = 0; r < regions.length; r++) {
		region = regions[r];
		waitForUser("Please select " + region + ", move the areas to their target position and click OK");
		
		roiPath = getInfo("image.directory")
					+ File.getNameWithoutExtension(getInfo("image.filename"))
					+ "." + region + ".roi.zip";
		roiManager("save", roiPath);

		for(c = 0; c < channels; c++) {
			Stack.setChannel(c + 1);
		
			Stack.getPosition(channel, slice, frame);
			
			row = nResults;
			setResult("File name", row, getInfo("image.filename"));
			setResult("Channel", row, channel);
			setResult("Region", row, region);
			setResult("Plane", row, slice);
		
			n = roiManager('count');
			sumIntInside = 0;
			sumIntTotal = 0;
			for (i = 0; i < n; i++) {
			    roiManager('select', i);
			    Roi.getBounds(rx, ry, rw, rh);
			    cx = rx + rw / 2;
			    cy = ry + rh / 2;
			    makeOval(cx - r1, cy - r1, 2 * r1, 2 * r1);
			    getStatistics(areaInside, meanInside, min, max, std, histogram);
			    intInside = areaInside * meanInside;
			    sumIntInside += intInside;
			    Roi.remove;
			    makeOval(cx - r2, cy - r2, 2 * r2, 2 * r2);
			    getStatistics(areaTotal, meanTotal, min, max, std, histogram);
			    intTotal = areaTotal * meanTotal;
			    sumIntTotal += intTotal;
			    Roi.remove;
			    setResult("Intravascular intensity "        + (i + 1), row, intInside);
			    setResult("Local intensity "                + (i + 1), row, intTotal);
			    setResult("Relative Vascular Permeability " + (i + 1), row, intInside / intTotal);
			}
			setResult("Cumulative Relative Vascular Intensity", row, sumIntInside / sumIntTotal);
			Roi.remove;
		}
	}
	updateResults();
}

function concatenate(table1, table2) {
	wasOpen = true;
	if(!isOpen(table1)) {
		Table.create(table1);
		wasOpen = false;
	}
	
	columns = split(Table.headings(table2), "\t");
	for(c = 0; c < columns.length; c++) {
		column = columns[c];
		trimmed = String.trim(column);
		if(trimmed.length == 0)
			continue;
		b = Table.getColumn(column, table2);
		
		if(wasOpen) {
			a = Table.getColumn(column, table1);
			b = Array.concat(a, b);
		}
		
		Table.setColumn(column, b, table1);
	}
}

function askToProcess() {
	Dialog.createNonBlocking("Process?");
	Dialog.addCheckbox("Skip this image", false);
	Dialog.addNumber("Size of one pixel in x/y", pixel_size, 5, 10, "um");
	Dialog.addNumber("Size of one pixel in z", axial_spacing, 5, 10, "um");
	Dialog.show();
	var skip = Dialog.getCheckbox();
	var dx = Dialog.getNumber();
	var dz = Dialog.getNumber();
	setVoxelSize(dx, dx, dz, "um");
	return skip;
}

function processFile(path) {
	var dir = File.getDirectory(path);
	resultFile = File.getNameWithoutExtension(path) + ".csv";
	if(File.exists(dir + resultFile)) {
		print("Skipping " + path);
		Table.open(dir + resultFile);
		Table.rename(resultFile);
	} else {
		print("Processing " + path);
		run("Bio-Formats",
			"open=[" + path + "] autoscale color_mode=Default view=Hyperstack stack_order=XYCZT");
		var title = getTitle();
		var skip = askToProcess();
		if(!skip) {
			processImage();
			Table.save(dir + resultFile, "Results");
			Table.rename("Results", resultFile);
		}
		close(title);
	}
	
	if(isOpen(resultFile)) {
		concatenate("entireTable", resultFile);
		selectWindow(resultFile);
		run("Close");
	}
}

function countFiles(dir) {
	list = getFileList(dir);

	for(i = 0; i < list.length; i++) {
		if(endsWith(list[i], "/"))
			count += countFiles(dir + list[i]);
		else if(indexOf(list[i], "ome.tif") >= 0)
			count++;
	}
	return count;
}

function processFiles(dir) {
	list = getFileList(dir);
	for(i = 0; i < list.length; i++) {
		if(endsWith(list[i], "/"))
			processFiles(dir + list[i]);
		else if(indexOf(list[i], "ome.tif") >= 0)
			processFile(dir + list[i]);
	}
}

if(isOpen("entireTable")) {
	showMessage("Please close 'entireTable' before running the macro");
	exit;
}

dir = getDirectory("Choose a Directory");
processFiles(dir);
Table.save(dir + "QuantificationResults.csv", "entireTable");
