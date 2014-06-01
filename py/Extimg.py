# coding=UTF-8

# Teux plugin for Serna, 2012

from SernaApi import *
from tempfile import NamedTemporaryFile
import httplib, urlparse, mimetypes 
from os import remove

class ExternalImages(DocumentPlugin):

	def __init__(self, a1, a2):
		DocumentPlugin.__init__(self, a1, a2)
		self.buildPluginExecutors(True)
		self.se = self.sernaDoc().structEditor()
		self.tmpImgs = []


	def beforeTransform(self):
		self.__ef = XsltExternalFunction('extImgToLocal','http://www.teux.ru/2010/XSL/functions')
		self.__ef.eval = self.extImgToLocal
		self.se.xsltEngine().registerExternalFunction(self.__ef)


	def extImgToLocal(self, params):
		href = str(params[0].getString())
		if href.startswith('http://'):
			urlparts = urlparse.urlsplit(href)
			h = httplib.HTTPConnection(urlparts[1])
			h.request('GET', href)
			
			tf = NamedTemporaryFile(suffix='.jpg', delete=False)
			tf.write(h.getresponse().read())
			tf.file.close()
			
			self.tmpImgs.append(tf)
			return XpathValue(tf.name)
		else:
			return XpathValue(href)
			
	
	def preClose(self):
		for f in self.tmpImgs:
			remove(f.name)
		return True 
		
