/**
 * @name example of placeholder
 * @description a basic query demo for placeholder
 * @kind problem
 * @problem.severity warning
 * @id java/basic
 */

import java

from Class c, Class superclass
where superclass = c.getASupertype()
select c, "This class extends the class $@.", superclass, superclass.getName()