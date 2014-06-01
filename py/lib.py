# coding=UTF-8

# Teux plugin for Serna, 2012

from SernaApi import *
import meta
from refs.keyref import keys


def textWithKeys(node, file):
	''' Returns node text with keys resolved '''
	text = ''
	for n in nset('node()[name() != "href"]', node):
		if n.nodeType() == 3:
			text += unicode(n.asGroveText().data())	# text node
		elif n.nodeType() == 1:
			keyref = vof('@keyref', n)
			if keyref != '':
				key = keys[file][keyref]
				if key == '':
					key = '<%s>' % keyref
				text += key
			else:
				text += vof('self::*', n)
	return text


def vof(xpath, node=None):
	'''	Returns attribute or element value '''
	if node is None and meta.contextNode:
		node = meta.contextNode
	if node:
		t = xpath.split('/')
		if t[len(t)-1].startswith('@'):
			return unicode(XpathExpr(xpath).eval(node).getNodeSet().\
			firstNode().asGroveAttr().value())
		else:
			return unicode(XpathExpr(xpath).eval(node).getString())


def nset(xpath, node = None):
	'''	Returns node set from grove '''
	if node is None and meta.contextNode:
		node = meta.contextNode
	if node:
		return XpathExpr(xpath).eval(node).getNodeSet()
		

def setRequiredAttribute(se, groveNode, groveAtt, attName, attValue):
	'''
		Sets the value of the required attribute
			se — StrucEditor
			groveNode — element node
			groveAtt — attribute node or None for new attribute
			attName — new name (it does not matter if groveAttr not None)  
			attValue — value
	'''
	if groveAtt:
		se.executeAndUpdate(se.groveEditor().setAttribute(groveAtt, attValue))
	elif  attValue != '' and attName != '':
		pn = PropertyNode(attName, attValue)
		cmd = se.groveEditor().addAttribute(groveNode.asGroveElement(), pn)
		se.executeAndUpdate(cmd)


def setOptionalAttribute(se, groveNode, groveAtt, attName, attValue):
	'''
		Sets the value of the optional attribute
			se — StrucEditor
			groveNode — element node in grove
			groveAtt — attribute node or None for new attribute
			attName — new name or empty string if no creation needed
			attValue — new value or empty string to delete attribute
	'''
	if groveAtt and attValue != '':
		se.executeAndUpdate(se.groveEditor().setAttribute(groveAtt, attValue))
	elif groveAtt and attValue == '':
		se.executeAndUpdate(se.groveEditor().removeAttribute(groveAtt))
	elif not groveAtt and attValue != '' and attName != '':
		pn = PropertyNode(attName, attValue)
		cmd = se.groveEditor().addAttribute(groveNode.asGroveElement(), pn)
		se.executeAndUpdate(cmd)
	se.setCursorBySrcPos(GrovePos(groveNode), groveNode)

		
class State():
	''' Stores end returns states '''
	
	def __init__(self, *pairs):
		''' Takes tuples of ('<unset>', '<set>'):
				<unset> corresponds unset state, <set> corresponds set state.
				Limit is is number of bit in int '''
		self.state = 0
		self.unsets = {}
		self.sets = {}
		bit = 1
		for pair in pairs:
			self.unsets[pair[0]] = bit
			self.sets[pair[1]] = bit
			bit <<= 1

	def set(self, states):
		''' Switches states on and off '''
		for s in states.split():
			if s in self.sets:
				self.state |= self.sets[s]
			elif s in self.unsets:
				self.state &= ~self.unsets[s]
	
	def get(self, states):
		''' Returns True if all states is set '''
		st = self._fillStates(states)
		return reduce(lambda x,y: x and y, st) if len(st) else False 
		
	def getOr(self, states):
		''' Returns True if any states is set '''
		st = self._fillStates(states)
		return reduce(lambda x,y: x or y, st) if len(st) else False
		
	def _fillStates(self, states):
		st = []
		for s in states.split():
			if s in self.sets:
				st.append(True if self.state & self.sets[s] else False)
			elif s in self.unsets:
				st.append(True if self.state & self.unsets[s] ^ self.unsets[s] else False)
		return st
		