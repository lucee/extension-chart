/**
* extensive.cfchart.tests.ChartSpec
*
* These tests cover various aspects of the Lucee <cfchart> tag.
* Focus is on error-free generation, output format validation,
* data source handling, and attribute usage. Visual verification
* is outside the scope of automated unit tests.
*/
component extends="org.lucee.cfml.test.LuceeTestCase" labels="chart" {

	function run( testResults , testBox ) {

		describe( "test base 64 rendering", function(){

			it( "base64 as data url", function(){
				savecontent variable="local.chartOutput" {
					cfchart( format="png", chartWidth=300, chartHeight=200, base64=true, showtooltip=false ) {
						cfchartseries( type="bar" ) {
							cfchartdata( item="Apples", value=50 );
							cfchartdata( item="Oranges", value=75 );
						};
					};
				};
				expect( local.chartOutput ).toInclude("data:image/png;base64");
			});

			it( "base64 as name", function(){
				cfchart( format="png", chartWidth=300, chartHeight=200, base64=true, name="local.chart", showtooltip=false ) {
					cfchartseries( type="bar" ) {
						cfchartdata( item="Apples", value=50 );
						cfchartdata( item="Oranges", value=75 );
					};
				};
				var img = ImageReadBase64( local.chart );
				expect( isImage(img) ).toBeTrue();
				var info = imageInfo( img );
				expect ( info.height ).toBe( 200 );
				expect ( info.width ).toBe( 300 );
				var imgFile = getTempFile(prefix="base64ChartAsName", ext="png");
				debug(img);
				ImageWrite( img, imgFile );
			});

			it( "throws an error when not png", function(){
				expect(function(){
					cfchart( format="jpeg", chartWidth=300, chartHeight=200, base64=true ) {
						cfchartseries( type="bar" ) {
							cfchartdata( item="Apples", value=50 );
							cfchartdata( item="Oranges", value=75 );
						};
					};
				}).toThrow();
			});

		});
	}
}