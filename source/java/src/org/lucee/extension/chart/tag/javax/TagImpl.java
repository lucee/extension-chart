/**
 *
 * Copyright (c) 2015, Lucee Assosication Switzerland
 * Copyright (c) 2014, the Railo Company Ltd. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either 
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public 
 * License along with this library.  If not, see <http://www.gnu.org/licenses/>.
 * 
 **/
package org.lucee.extension.chart.tag.javax;

import javax.servlet.jsp.tagext.Tag;

import lucee.loader.engine.CFMLEngine;
import lucee.loader.engine.CFMLEngineFactory;
import lucee.loader.util.Util;
import lucee.runtime.PageContext;
import lucee.runtime.exp.PageException;

/**
 * Implementation of the Tag
 */
public abstract class TagImpl implements Tag {

	protected transient PageContext pageContext;
	private transient Tag parent;
	private transient CFMLEngine eng;

	public CFMLEngine eng() {
		if (eng == null) eng = CFMLEngineFactory.getInstance();
		return eng;
	}

	/**
	 * sets a PageContext
	 * 
	 * @param pageContext
	 */
	public void setPageContext(PageContext pageContext) {
		this.pageContext = pageContext;
	}

	@Override
	public void setPageContext(javax.servlet.jsp.PageContext pageContext) {
		this.pageContext = CFMLEngineFactory.getInstance().getThreadPageContext();
	}

	@Override
	public void setParent(Tag parent) {
		this.parent = parent;
	}

	@Override
	public Tag getParent() {
		return parent;
	}

	@Override
	public int doStartTag() {
		return SKIP_BODY;
	}

	@Override
	public int doEndTag() {
		return EVAL_PAGE;
	}

	@Override
	public void release() {
		pageContext = null;
		parent = null;
		eng = null;
	}

	/**
	 * check if value is not empty
	 * 
	 * @param tagName
	 * @param attributeName
	 * @param attribute
	 */
	public void required(String tagName, String actionName, String attributeName, Object attribute) throws PageException {
		if (attribute == null) throw eng().getExceptionUtil()
				.createApplicationException("Attribute [" + attributeName + "] for tag [" + tagName + "] is required if attribute action has the value [" + actionName + "]");

	}

	public void required(String tagName, String attributeName, Object attribute) throws PageException {
		if (attribute == null) throw eng().getExceptionUtil().createApplicationException("Attribute [" + attributeName + "] for tag [" + tagName + "] is required");

	}

	public void required(String tagName, String actionName, String attributeName, String attribute, boolean trim) throws PageException {
		if (Util.isEmpty(attribute, trim)) throw eng().getExceptionUtil()
				.createApplicationException("Attribute [" + attributeName + "] for tag [" + tagName + "] is required if attribute action has the value [" + actionName + "]");
	}

	public void required(String tagName, String actionName, String attributeName, double attributeValue, double nullValue) throws PageException {
		if (attributeValue == nullValue) throw eng().getExceptionUtil()
				.createApplicationException("Attribute [" + attributeName + "] for tag [" + tagName + "] is required if attribute action has the value [" + actionName + "]");
	}
}