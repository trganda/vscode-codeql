// Generated automatically from org.springframework.web.bind.annotation.RequestMapping for testing purposes

package org.springframework.web.bind.annotation;

import java.lang.annotation.Annotation;
import java.lang.annotation.Documented;
import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;
import org.springframework.web.bind.annotation.Mapping;
import org.springframework.web.bind.annotation.RequestMethod;

@Documented
@Retention(value=java.lang.annotation.RetentionPolicy.RUNTIME)
@Target(value={java.lang.annotation.ElementType.TYPE,java.lang.annotation.ElementType.METHOD})
@Mapping
public @interface RequestMapping
{
    RequestMethod[] method() default {};
    String name() default "";
    String[] consumes() default {};
    String[] headers() default {};
    String[] params() default {};
    String[] path() default {};
    String[] produces() default {};
    String[] value() default {};
}
