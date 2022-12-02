 PROGRAM
 MAP
 END

 INCLUDE('ABPRXML.INC'),ONCE

XML XMLGenerator

 CODE

!The XML file created

!<breakfast_menu>
!   <food recordNumber="1">
!      <name>Belgian Waffles</name>
!      <price>$5.95</price>
!      <description>
!      two of our famous Belgian Waffles with plenty of real maple syrup
!      </description>
!      <calories>650</calories>
!   </food>
!   <food recordNumber="2">
!      <name>Strawberry Belgian Waffles</name>
!      <price>$7.95</price>
!      <description>
!      light Belgian waffles covered with strawberries and whipped cream
!      </description>
!      <calories>900</calories>
!   </food>
!</breakfast_menu>

    XML.Init('breakfast_menu.XML')
    XML.OpenDocument()
    XML.SetEncoding('ISO-8859-1')

    XML.SetRootTag('breakfast_menu')
    XML.AddComment('The root tag is the first tag in the doc')
    
    XML.AddTag('food','')
    XML.AddAttribute('recordNumber','1','food')
    XML.AddTag('name','Belgian Waffles',false,'food')
    XML.AddTag('price','$5.95',false,'food')
    XML.AddTag('description','two of our famous Belgian Waffles with plenty of real maple syrup',false,'food')
    XML.AddTag('calories','650',false,'food')

    XML.AddTag('food','')
    XML.AddAttribute('recordNumber','2','food')
    XML.AddTag('name','Strawberry Belgian Waffles',false,'food')
    XML.AddTag('price','$7.95',false,'food')
    XML.AddTag('description','light Belgian waffles covered with strawberries and whipped cream',false,'food')
    XML.AddTag('calories','900',false,'food')

    XML.CloseDocument()