// ==UserScript==
// @name         Hide MSDN translation popup
// @namespace    https://github.com/surrogard
// @version      0.1
// @description  Hides the annoying translation/original popup that shows everytime you hover over a sentence
// @author       Surrogard
// @match        https://msdn.microsoft.com/de-de/library/*
// @grant        none
// ==/UserScript==

(function init()
{
    var counter = document.getElementById('popup0');
    if (counter)
    {
        document.getElementById("popup0").style.visibility = "hidden";
    }
    else
    {
        setTimeout(init, 0);
    }
})();