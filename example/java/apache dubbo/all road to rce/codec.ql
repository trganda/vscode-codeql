/**
 * @name attack surface
 * @kind problem
 * @problem.severity warning
 * @id org/trganda/java/dubbo
 */

import java

class Codec2Class extends Class {
    Codec2Class() {
        this.getASourceSupertype*().hasQualifiedName("org.apache.dubbo.remoting", "Codec2")
    }
}

from Codec2Class codec2
select codec2, codec2.getName()
