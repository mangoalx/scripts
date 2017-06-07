import sys
import xml.dom.minidom

# check for regression between two CTS result
# if test are fail in base and pass in "against", it is a regression

base_cts_name = sys.argv[1]
against_cts_name = sys.argv[2]

basedom = xml.dom.minidom.parse(base_cts_name)
againstdom = xml.dom.minidom.parse(against_cts_name)

def getNodeABI(node):
    while node.parentNode:
        node = node.parentNode
        if node.hasAttribute("abi"):
            return node.getAttribute("abi")

for test in basedom.getElementsByTagName("Test"):
    if test.getAttribute("result") == "fail":
        for test_old in againstdom.getElementsByTagName("Test"):
            if test.getAttribute("name") == test_old.getAttribute("name") and getNodeABI(test) == getNodeABI(test_old):
                if test_old.getAttribute("result") == "pass":
                    print getNodeABI(test) + "," + test.parentNode.getAttribute("name") + "," + test.getAttribute("name")
                break