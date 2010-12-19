LINK_REGEX = /(\[(.+?)\])?\(?([A-Za-z]+:\/\/[A-Za-z0-9-_]+\.[A-Za-z0-9-_:;#\+%&\?\/.=]+)\)?/g;

function $(el) { return document.getElementById(el); }

function replaceHTMLCharacters(string)
{
	return string.replace(/<\/?[^>]+>/gi, '').replace(/&lt;/g,'<').replace(/&gt;/g,'>').replace(/&amp;/g,'&');
}

function replaceHTMLCharactersInElement(element)
{
	var childNodes = element.childNodes,
		count = childNodes.length;
		
	for (var i=0; i<count; i++)
		childNodes[i].innerText = replaceHTMLCharacters(childNodes[i].innerText);
}

function howLongAgoString(aTime)
{
	var aTimeInterval = Math.abs(((new Date().getTime())/1000) - aTime);
		
	if (aTimeInterval <= 1)
		return "1 second";
	
	if (aTimeInterval < 60)
		if (aTimeInterval >= 30)
			return "half a minute";
		else
			return Math.floor(aTimeInterval) + " seconds";
	
	var time = Math.floor(aTimeInterval / 60);
	
	if (time < 60)
		if (time === 1)
			return "1 minute";
		else
			return time + " minutes";
	
	time = Math.floor(aTimeInterval / (60 * 60));
	
	if (time < 24)
		if (time === 1)
			return "1 hour";
		else
			return time + " hours";
	
	time = Math.floor(aTimeInterval / (60 * 60 * 24));
		
	if (time < 30)
		if (time == 1)
			return "1 day";
		else 
			return time + " days";
	
	time = Math.floor(aTimeInterval / (60.0 * 60.0 * 24.0 * 30.0));
	
	if (time < 12)
		if (time == 1)
			return "1 month";
		else 
			return time + " months";

	time = Math.floor(aTimeInterval / (60.0 * 60.0 * 24.0 * 30.0 * 12.0));
	
	if (time == 1)
		return "1 year";
	
	return time + " years";
}

function replaceLinksInElement(element)
{
	var string = element.innerText;
	
	element.innerHTML = "";
	
	var span = document.createElement("span"),
		currentIndex = 0,
		result;
	
	while(result = LINK_REGEX.exec(string))
	{
		var match = result[0],
			matchIndex = string.indexOf(match);
		
		span.innerText = string.substring(currentIndex, matchIndex);
		element.appendChild(span);
		
		var link = document.createElement("a");
		
		link.href = result[3];
		
		link.onclick = function(anEvent)
		{
			window.location.href = this.href;
			anEvent.stopPropagation();
		}
		
		if (result[2])
			link.innerText = result[2];
		else
			link.innerText = result[3];
			
		element.appendChild(link);
		
		currentIndex = matchIndex+match.length;
		
		span = document.createElement("span");
	}

	span.innerText = string.substring(currentIndex);
	element.appendChild(span);
}

if (window.location.search)
{
	var searchParams = window.location.search.substring(1).split("&"),
		arguments = {};
		
	for(var i=0; i<searchParams.length; i++)
	{
		var index = searchParams[i].indexOf('=');
		
		if(index == -1)
			arguments[searchParams[i]] = "";
		else
			arguments[searchParams[i].substring(0, index)] = decodeURIComponent(searchParams[i].substring(index+1));
	}
	
	window.STORY_ID = arguments["id"];
}
else
{
	var arguments = {
		title:      "__TITLE__",
		domain:     "__DOMAIN__",
		id:         "__ID__",
		created:    "__CREATED__",
		author:     "__AUTHOR__" 
	};
}

window.title = decodeURIComponent(arguments["title"]);

if (arguments["title"] && arguments["title"] != "(null)")
	$("storytitle").innerText   = decodeURIComponent(arguments["title"]);

$("storydomain").innerText  = arguments["domain"];
$("storyid").innerText	  = arguments["id"];  
$("storydate").innerText	= howLongAgoString(parseInt(arguments["created"], 10))+" ago";
$("storyauthor").innerText  = arguments["author"];

JUMP_TO  = decodeURIComponent(arguments["jump"]);
BASE_URL = decodeURIComponent(arguments["base"]);

var xhr = new XMLHttpRequest();

xhr.open("GET", BASE_URL+"/comments/"+STORY_ID+"/.json", true);

xhr.setRequestHeader("x-reddit-version", "2.1");

xhr.onreadystatechange = function()
{
	if (xhr.readyState == 4)
	{
		$("REPLY").className = "visible";
		$("COMMENTS").innerHTML = "";
		$("META").innerHTML = "Tap a comment to vote or reply.";
		
		//fill out the header
		DATASET = eval("("+xhr.responseText+")");
		var story  = DATASET[0].data.children[0].data;
			
		$("storyid").innerText	  = story.id;	
		$("storytitle").innerText   = replaceHTMLCharacters(story.title);
		$("storydomain").innerText  = story.domain;
		$("storydate").innerText	= howLongAgoString(story.created_utc)+" ago";
		$("storyauthor").innerText  = story.author; 

		if (story.selftext)
		{
			$("selfpost").innerHTML = replaceHTMLCharacters(story.selftext_html);
		}
		
		$("REPLY_submit").onclick = function(anEvent)
		{					
			if (!window.MODHASH)
				return window.location.href="http://login";
				
			var request = new XMLHttpRequest();
			
			request.open("POST", BASE_URL+"/api/comment", true);
			request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
			request.setRequestHeader("x-reddit-version", "1.1");

			request.onreadystatechange = function()
			{
				if (request.readyState == 4)
				{
					var responseData;
					
					try {
						responseData = eval("("+request.responseText+")").json;
					}
					catch (e){}
					
					if (responseData && responseData.data && responseData.data.things && 
						responseData.data.things[0] && responseData.data.things[0].data)
					{
						var resultingPost = responseData.data.things[0].data;
						
						var theComment = createCommentElement(
						{
							data: {
								likes: true,
								name: resultingPost.id,
								id: resultingPost.id.substring(3),
								body: $("reply-textarea").value,
								contentHTML: resultingPost.contentHTML,
								created_utc: (new Date()).getTime()/1000,
								author: "me",
								ups: 1,
								downs: 0
							}
						}, 0);
					
						$("COMMENTS").insertBefore(theComment, $("COMMENTS").childNodes[0]);
						
						$("reply-textarea").value = "";
						$("REPLY_status").className = "";
					}
					else
					{
						$("REPLY_status").innerText = "Post failed. Try again in a few minutes.";
					}						

					$("REPLY_submit").disabled = false;
				}
			};

			request.send("isroot=1&api_type=json&r="+encodeURIComponent(DATASET[0].data.children[0].data.subreddit)+"&uh="+window.MODHASH+
						 "&thing_id="+story.name+"&text="+encodeURIComponent($("reply-textarea").value)+"&_=");
							
			$("REPLY_submit").disabled = true;
			$("REPLY_status").innerText = "Submitting...";
			$("REPLY_status").className = "visible";
			
			anEvent.stopPropagation();
		}
	  
		//a function to layout a comment element 
		function createCommentElement(comment, recursionLevel)
		{
			var element = document.createElement("div"),
				data = comment.data;
		
			if (!data.body)
				return element;
				
			//first keep track of the global scoring/voting data
			if (data.likes != undefined && data.likes === true) {
				VOTES[data.name] = 1;
				element.className = "comment voted-up";
			}
			else if (data.likes != undefined && data.likes === false) {
				VOTES[data.name] = -1;
				element.className = "comment voted-down";
			}
			else {
				VOTES[data.name] = 0;
				element.className = "comment not-voted";
			}
				
			SCORES[data.name] = data.ups - data.downs - VOTES[data.name];
				
			element.id = data.id;
			
			var header = document.createElement("div");
			header.className="comment-header";
			
			element.appendChild(header);
			
			var toggleControl = document.createElement("span");
			
			toggleControl.innerText = "[-] ";
			toggleControl.className = "comment-toggle-control";
			toggleControl.id = data.id+"_comment_control";
			
			header.appendChild(toggleControl);
			
			var commentAuthor = document.createElement("span");
			
			commentAuthor.className = "comment-author";
			commentAuthor.id = data.id+"_author";
			commentAuthor.innerText = data.author;
		
			header.appendChild(commentAuthor);
			
			var commentPoints = document.createElement("span");
			
			commentPoints.className = "comment-points";
			commentPoints.id = data.id+"_points";
			commentPoints.innerText = " "+(SCORES[data.name]+VOTES[data.name])+" points ";
				
			header.appendChild(commentPoints);
			
			var commentPoints = document.createElement("span");
			
			commentPoints.className = "comment-date";
			commentPoints.id = data.id+"_date";
			commentPoints.innerText = howLongAgoString(data.created_utc)+" ago";
						
			header.appendChild(commentPoints);
	
	
			header.active = true;
			header.onclick = function(anEvent)
			{
				if (this.active)
				{
					if (window.SELECTED && window.SELECTED == $(data.id))
						window.SELECTED.unselect();
					
					$(data.id+'_children').className = "comment-children hidden";
					$(data.id+'_comment').className = "comment-body hidden";
					toggleControl.innerText = "[+] ";
				}
				else
				{
					$(data.id+'_children').className = "comment-children";
					$(data.id+'_comment').className = "comment-body";
					toggleControl.innerText = "[-] ";
				}

				this.active = !this.active;
			}
			
	
			var commentBody = document.createElement("div");
			
			commentBody.className = "comment-body";
			commentBody.id = data.id+"_comment";
			commentBody.innerHTML = replaceHTMLCharacters(data.body_html || data.contentHTML || data.body || data.textContent || "");
			
			//replaceLinksInElement(commentBody);
			//replaceHTMLCharactersInElement(commentBody);
			
			if (data.ups - data.downs < 0)
				commentBody.className = "comment-body negative";

			element.appendChild(commentBody);
			
			var commentReply = document.createElement("div");
			
			commentReply.className = "comment-reply";
			commentReply.id = data.id+"_reply";
			
			element.appendChild(commentReply);
			
			var commentReplyPadding = document.createElement("div");
			
			commentReplyPadding.className = "comment-reply-padding";
			commentReplyPadding.id = data.id+"_reply_padding";
			
			element.appendChild(commentReplyPadding);
			
			var commentStatus = document.createElement("div");
			
			commentStatus.className = "comment-status";
			commentStatus.id = data.id+"_status";
			
			commentReply.appendChild(commentStatus);
			
			var commentTextArea = document.createElement("textarea");
			
			commentTextArea.className = "comment-reply-textarea";
			commentTextArea.id = data.id+"_textarea";
			
			commentReply.appendChild(commentTextArea);
			
			var commentControls = document.createElement("div");
			commentControls.className = "comment-controls";
			commentReply.appendChild(commentControls);
			
			var commentCancelButton = document.createElement("button");
			
			commentCancelButton.type = "button";
			commentCancelButton.className = "comment-cancel-button";
			commentCancelButton.innerHTML = "cancel";
			//commentCancelButton.style.clear = "left";
			
			commentCancelButton.onclick = function(anEvent)
			{
				commentTextArea.value = "";
				
				if (window.SELECTED)
					window.SELECTED.unselect();
					
				anEvent.stopPropagation();
			}
			
			commentControls.appendChild(commentCancelButton);

			var commentSubmitButton = document.createElement("button");
			
			commentSubmitButton.type = "button";
			commentSubmitButton.innerHTML = "reply";
	   
			commentSubmitButton.onclick = function(anEvent)
			{					
				if (!window.MODHASH)
					return window.location.href="http://login";
					
				var request = new XMLHttpRequest();
				
				request.open("POST", BASE_URL+"/api/comment", true);
				request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
				request.setRequestHeader("x-reddit-version", "1.1");

				request.onreadystatechange = function()
				{
					if (request.readyState == 4)
					{
						var responseData;
						
						try {
							responseData = eval("("+request.responseText+")").json;
						}
						catch (e){}

						if (responseData && responseData.data && responseData.data.things && 
							responseData.data.things[0] && responseData.data.things[0].data)
						{
							var resultingPost = responseData.data.things[0].data;
							
							var theComment = createCommentElement(
							{
								data: {
									likes: true,
									name: resultingPost.id,
									id: resultingPost.id.substring(3),
									body: commentTextArea.value,
									contentHTML: resultingPost.contentHTML,
									created_utc: (new Date()).getTime()/1000,
									author: "me",
									ups: 1,
									downs: 0
								}
							}, 0);

							$(element.id+"_children").insertBefore(theComment, $(element.id+"_children").firstChild);
							
							commentTextArea.value = "";
							commentStatus.className = "comment-status";
							element.unselect();
						}
						else
						{
							commentStatus.innerText = "Post failed. Try again in a few minutes.";
							commentStatus.className = "comment-status failed";
						}						

						commentSubmitButton.disabled = false;
					}
				};

				request.send("api_type=json&r="+encodeURIComponent(DATASET[0].data.children[0].data.subreddit)+"&uh="+window.MODHASH+
							 "&parent="+data.name+"&comment="+encodeURIComponent(commentTextArea.value)+"&_=");
								
				commentSubmitButton.disabled = true;
				commentStatus.innerText = "Submitting...";
				commentStatus.className = "comment-status visible";
				
				anEvent.stopPropagation();
			}
 
			commentControls.appendChild(commentSubmitButton);

			var commentVotingControls = document.createElement("div");
			commentVotingControls.className = "comment-voting-controls";
			commentReply.appendChild(commentVotingControls);
			
			//commentVotingControls = commentControls;

			var commentVoteDownButton = document.createElement("button");
			
			commentVoteDownButton.type = "button";
			commentVoteDownButton.className = "vote-down";
			commentVoteDownButton.innerHTML = "vote down";
			
			
			commentVoteDownButton.onclick = function(anEvent)
			{
				if (!window.MODHASH)
					return window.location.href="http://login";
				
				if (VOTES[data.name] == -1)
					VOTES[data.name] = 0;
				else
					VOTES[data.name] = -1;
				
				if (VOTES[data.name] == -1) {
					$(data.id).className = "comment voted-down";
				}
				else {
					$(data.id).className = "comment not-voted";
				}

				$(data.id+"_points").innerText = " "+(SCORES[data.name]+VOTES[data.name])+" points ";
				
				var request = new XMLHttpRequest();
				
				request.open("POST", BASE_URL+"/api/vote", true);
				request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
				request.setRequestHeader("x-reddit-version", "1.1");

				request.send("r="+encodeURIComponent(DATASET[0].data.children[0].data.subreddit)+"&uh="+window.MODHASH+
							 "&id="+data.name+"&dir="+VOTES[data.name]+"&_=");
				
				anEvent.stopPropagation();
			}

			commentVotingControls.insertBefore(commentVoteDownButton, commentVotingControls.firstChild);

			var commentVoteUpButton = document.createElement("button");

			commentVoteUpButton.type = "button";
			commentVoteUpButton.innerHTML = "vote up";
			commentVoteUpButton.className = "vote-up";
			
			commentVoteUpButton.onclick = function(anEvent)
			{
				if (!window.MODHASH)
					return window.location.href="http://login";
				
				if (VOTES[data.name] == 1)
					VOTES[data.name] = 0;
				else
					VOTES[data.name] = 1;
				
				if (VOTES[data.name] == 1) {
					$(data.id).className = "comment voted-up";
				}
				else {
					$(data.id).className = "comment not-voted";
				}

				$(data.id+"_points").innerText = " "+(SCORES[data.name]+VOTES[data.name])+" points ";

				var request = new XMLHttpRequest();
				
				request.open("POST", BASE_URL+"/api/vote", true);
				request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
				request.setRequestHeader("x-reddit-version", "1.1");

				request.send("r="+encodeURIComponent(DATASET[0].data.children[0].data.subreddit)+"&uh="+window.MODHASH+
							 "&id="+data.name+"&dir="+VOTES[data.name]+"&_=");
				
				anEvent.stopPropagation();
			}
			
			commentVotingControls.insertBefore(commentVoteUpButton, commentVotingControls.firstChild);

			
			var commentChildren = document.createElement("div");
			
			commentChildren.className = "comment-children";
			commentChildren.id = data.id+"_children";
			
			if (data.replies)
			{
				var replies = data.replies.data.children;
				
				for (var i=0; i<replies.length; i++)
					commentChildren.appendChild(createCommentElement(replies[i], recursionLevel+1));
					
			}
	
			element.appendChild(commentChildren);
			
			commentBody.onclick = function(anEvent)
			{
				if (anEvent.target.nodeName !== "A")
				{
					element.select();
					anEvent.stopPropagation();

					return false;
				}
			};
			
			element.select = function()
			{
				if (window.SELECTED && window.SELECTED == this)
					return;
					
				if (window.SELECTED)
					window.SELECTED.unselect();
							
				window.SELECTED = this;
	
				$(this.id+"_reply").className = "comment-reply visible";
				$(this.id+"_reply_padding").className = "comment-reply-padding visible";

				$(this.id+"_comment").className += " selected";

				//scrollBy(0, -100);
			};
			
			element.unselect = function()
			{
				$(this.id+"_comment").style.backgroundColor = "transparent";

				$(this.id+"_reply").className = "comment-reply";
				$(this.id+"_reply_padding").className = "comment-reply-padding";
				$(this.id+"_comment").className = $(this.id+"_comment").className.replace(" selected", "");

			   window.SELECTED = null;
				
				//scrollBy(0, 100);
			};
			
			TOTAL_COMMENTS++;
			return element;
		}
	
		//write out each comment
	   
		if (DATASET.length < 2 || !DATASET[1].data || !DATASET[1].data.children)
			return;
			
		var comments = DATASET[1].data.children,
			commentElement = $("COMMENTS");
		
		TOTAL_COMMENTS = 0;
		SCORES = {};
		VOTES = {};
		
		for (var i=0; i<comments.length; i++)
			commentElement.appendChild(createCommentElement(comments[i], 0));
					
		if (JUMP_TO && $(JUMP_TO)) {
			window.setTimeout(function(){
				window.scrollTo(0, $(JUMP_TO).offsetTop);
				$(JUMP_TO).select();
			}, 500);
		}
	 }
}

xhr.send("");