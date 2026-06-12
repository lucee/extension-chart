package org.lucee.extension.chart.util;

import java.awt.image.BufferedImage;
import java.io.IOException;
import java.io.OutputStream;
import java.util.Iterator;

import javax.imageio.IIOImage;
import javax.imageio.ImageIO;
import javax.imageio.ImageTypeSpecifier;
import javax.imageio.ImageWriteParam;
import javax.imageio.ImageWriter;
import javax.imageio.metadata.IIOMetadata;
import javax.imageio.stream.ImageOutputStream;

import lucee.runtime.exp.PageException;

public class ImageUtil {

	private static final int QUALITY = 1;

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
		IIOMetadata meta = null;

		ImageWriter writer = null;
		ImageTypeSpecifier type = ImageTypeSpecifier.createFromRenderedImage(im);
		Iterator<ImageWriter> iter = ImageIO.getImageWriters(type, "png");

		if (iter.hasNext()) {
			writer = iter.next();
		}
		if (writer == null) throw new IOException("no writer for format [png] found!");

		ImageWriteParam iwp = writer.getDefaultWriteParam();

		try {
			iwp.setCompressionMode(ImageWriteParam.MODE_EXPLICIT);
		}
		catch (Exception t) {
		}
		try {
			iwp.setCompressionQuality(QUALITY);
		}
		catch (Exception t) {
		}
		writer.setOutput(ios);
		try {
			writer.write(meta, new IIOImage(im, null, meta), iwp);
		}
		finally {
			writer.dispose();
			ios.flush();
		}
	}
}
