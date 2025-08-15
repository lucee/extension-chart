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
				
				// Verify it's a valid base64 string
				expect( isDefined("local.chart") ).toBeTrue();
				expect( len(local.chart) ).toBeGT( 0 );
				
				// Check if it starts with the PNG base64 signature
				// PNG files always start with these bytes: 89 50 4E 47 0D 0A 1A 0A
				// In base64, this becomes: iVBORw0KGgo
				expect( left(local.chart, 11) ).toBe( "iVBORw0KGgo" );
				
				// decode base64 and check PNG signature
				var decoded = toBinary(local.chart);
				var binaryStr = binaryEncode(decoded, "hex");
				
				// PNG signature in hex: 89504E470D0A1A0A
				expect( left(binaryStr, 16) ).toBe( "89504E470D0A1A0A" );
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