package org.lucee.extension.chart.util;

import java.awt.image.BufferedImage;
import java.io.IOException;
import java.io.OutputStream;
import java.util.Iterator;

import javax.imageio.ImageIO;
import javax.imageio.ImageTypeSpecifier;
import javax.imageio.ImageWriter;
import javax.imageio.stream.ImageOutputStream;

import lucee.runtime.exp.PageException;

public class ImageUtil {

	/**
	 * writes the image as GIF, using the GIF writer that comes with the JDK
	 */
	public static void writeOut(BufferedImage bi, OutputStream os) throws IOException, PageException {
		ImageOutputStream ios = ImageIO.createImageOutputStream(os);
		try {
			_writeOut(bi, ios);
		}
		finally {
			try {
				ios.close();
			}
			catch (Exception t) {
			}
		}
	}

	private static void _writeOut(BufferedImage im, ImageOutputStream ios) throws IOException, PageException {
		ImageTypeSpecifier type = ImageTypeSpecifier.createFromRenderedImage(im);
		Iterator<ImageWriter> iter = ImageIO.getImageWriters(type, "gif");
		if (!iter.hasNext()) throw new IOException("no writer for format [gif] found!");

		ImageWriter writer = iter.next();
		writer.setOutput(ios);
		try {
			writer.write(im);
		}
		finally {
			writer.dispose();
			ios.flush();
		}
	}
}
