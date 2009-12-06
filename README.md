CocoaMondoKit
-------------

CocoaMondoKit is an Interface Builder plugin. The plugin currently only 
contains one interface  component. The Zoomable Text Field; formally 
known as the [Mondo Text Field][1].


Usage
-----

 1. Compile in Xcode.
 2. Double click CocoaMondoKit.ibplugin to load the plugin into 
Interface Builder. (Notez Bien: Interface builder will reference 
the file instead of copying it.  Keep the .ibplugin file in a 
location it won't be deleted.)
 3. In the Xcode project you want to use the plugin:
*  Right click the Linked Frameworks folder and click **Add -> Existing Frameworks**.  
*  Select the CocoaMondoKit.framework directory.
*  Right click your target and click 
**Add -> New Build Phase -> New Copy Files Build Phase**.  For desitination, 
select Frameworks, leave the path field blank, and close the window.
*  Drag the CocoaMondoKit framework from Linked Frameworks to the Copy 
Files build phase you just added.

To reference CocoaMondoKit objects in your kode, simply import the main header file.

    #import <CocoaMondoKit/CocoaMondoKit.h>

License
------
I'm not liable for anything but give me props if you use the kode in your application.   

Kudos
-----
Many thanks to Brandon Walkin for releasing [BWToolkit][2] as open source.  
At times poking at the BWToolkit source code was much more useful than 
official [Interface Builder plugin documentation][3].


  [1]: http://sunflower.coleharbour.ca/cocoamondo/2008/12/the-mondotextfield-a-formal-introduction/
  [2]: http://www.brandonwalkin.com/bwtoolkit/
  [3]: http://developer.apple.com/mac/library/documentation/DeveloperTools/Conceptual/IBPlugInGuide/Introduction/Introduction.html
