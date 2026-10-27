# Breaking Changes

Behaviour changes in 3.0 (Maven-based extension for Lucee 7.1+) that may affect existing Lucee applications, compared to 2.0.

## Requires Lucee 7.1 ([LDEV-6398](https://luceeserver.atlassian.net/browse/LDEV-6398))

The extension no longer ships OSGi bundles. Its Java code and dependencies are loaded as Maven artifacts (`maven=` in the tag definition), which needs Lucee 7.1 or newer (`luceeCoreVersion` in `pom.xml`). On Lucee 6.x / 7.0 stay on Chart 2.0.

The `.lite.lex` does not contain the dependencies, so Lucee downloads them from Maven Central when the extension is installed. On servers without access to Maven Central, use the full `.lex`.

## JFreeChart 1.0.19 → 1.5.6

- The bundled OSGi jars `org.jfree.chart` / `org.jfree.common` (JCommon) are gone. Code that calls JFreeChart directly through `createObject("java", "org.jfree...")` without loading the library itself no longer finds the classes. Load `org.jfree:jfreechart` through Maven instead, and expect the 1.5 API: JCommon classes such as `org.jfree.ui.*` and `org.jfree.util.*` no longer exist.
- JFreeChart 1.5 no longer has 3D renderers for category charts, so `show3d="true"` on **bar**, **horizontalbar** and **line** charts now renders a flat chart. 3D **pie** charts still render in 3D.

## JAI removed

The Java Advanced Imaging (JAI) jars are no longer part of the extension. Images are written with the JDK's `ImageIO`.

## `showborder` drawn by JFreeChart

`showborder="true"` (or a colour) now draws the border inside the chart with JFreeChart, instead of adding a 1px frame to the rendered image afterwards. The border can look slightly different.
