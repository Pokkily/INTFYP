<%@ Page Async="true" Title="Korean Learning" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="Korean.aspx.cs" Inherits="YourNamespace.Korean" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Korean Learning
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Header -->
    <section class="text-center bg-light py-4 border rounded mb-4">
        <div class="container">
            <h1 class="display-5 fw-bold">Korean Language</h1>
            <p class="lead text-muted">Track your lesson progress and continue learning.</p>
        </div>
    </section>

    <div class="container">
    <div class="row justify-content-center">
        <div class="col-md-8">

            <!-- Topic 0: Travel -->
            <div class="card mb-3 shadow-sm">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <h5 class="mb-0">Topic: Travel</h5>
                    <button class="btn btn-sm btn-outline-primary" type="button" data-bs-toggle="collapse" data-bs-target="#travelLessons" aria-expanded="false" aria-controls="travelLessons">
                        View Lessons
                    </button>
                </div>
                <div class="collapse" id="travelLessons">
                    <div class="card-body">
                        <!-- Travel Lessons -->
                        <div class="card mb-2 shadow-sm">
                            <div class="card-body d-flex justify-content-between align-items-center">
                                <div>
                                    <h6 class="card-title mb-1">Travel Lesson 1</h6>
                                    <asp:Literal ID="travelLesson1StatusLiteral" runat="server" />
                                </div>
                                <a href="TravelLesson1.aspx" class="btn btn-primary">Start</a>
                            </div>
                        </div>
                        <div class="card mb-2 shadow-sm">
                            <div class="card-body d-flex justify-content-between align-items-center">
                                <div>
                                    <h6 class="card-title mb-1">Travel Lesson 2</h6>
                                    <asp:Literal ID="travelLesson2StatusLiteral" runat="server" />
                                </div>
                                <a href="TravelLesson2.aspx" class="btn btn-primary">Start</a>
                            </div>
                        </div>
                        <div class="card mb-2 shadow-sm">
                            <div class="card-body d-flex justify-content-between align-items-center">
                                <div>
                                    <h6 class="card-title mb-1">Travel Lesson 3</h6>
                                    <asp:Literal ID="travelLesson3StatusLiteral" runat="server" />
                                </div>
                                <a href="TravelLesson3.aspx" class="btn btn-primary">Start</a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Topic 2: Coffee Shop -->
            <div class="card mb-3 shadow-sm">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <h5 class="mb-0">Topic: Coffee Shop</h5>
                    <button class="btn btn-sm btn-outline-primary" type="button" data-bs-toggle="collapse" data-bs-target="#coffeeLessons" aria-expanded="false" aria-controls="coffeeLessons">
                        View Lessons
                    </button>
                </div>
                <div class="collapse" id="coffeeLessons">
                    <div class="card-body">
                        <!-- Lesson cards -->
                        <div class="card mb-2 shadow-sm">
                            <div class="card-body d-flex justify-content-between align-items-center">
                                <div>
                                    <h6 class="card-title mb-1">Coffee Shop Lesson 1</h6>
                                    <asp:Literal ID="lesson1StatusLiteral" runat="server" />
                                </div>
                                <a href="Klesson1.aspx" class="btn btn-dark">Start</a>
                            </div>
                        </div>
                        <div class="card mb-2 shadow-sm">
                            <div class="card-body d-flex justify-content-between align-items-center">
                                <div>
                                    <h6 class="card-title mb-1">Coffee Shop Lesson 2</h6>
                                    <asp:Literal ID="lesson2StatusLiteral" runat="server" />
                                </div>
                                <a href="Klesson2.aspx" class="btn btn-dark">Start</a>
                            </div>
                        </div>
                        <div class="card mb-2 shadow-sm">
                            <div class="card-body d-flex justify-content-between align-items-center">
                                <div>
                                    <h6 class="card-title mb-1">Coffee Shop Lesson 3</h6>
                                    <asp:Literal ID="lesson3StatusLiteral" runat="server" />
                                </div>
                                <a href="Klesson3.aspx" class="btn btn-dark">Start</a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Topic 3: Market -->
            <div class="card mb-3 shadow-sm">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <h5 class="mb-0">Topic: Market</h5>
                    <button class="btn btn-sm btn-outline-success" type="button" data-bs-toggle="collapse" data-bs-target="#marketLessons" aria-expanded="false" aria-controls="marketLessons">
                        View Lessons
                    </button>
                </div>
                <div class="collapse" id="marketLessons">
                    <div class="card-body">
                        <!-- Lesson cards -->
                        <div class="card mb-2 shadow-sm">
                            <div class="card-body d-flex justify-content-between align-items-center">
                                <div>
                                    <h6 class="card-title mb-1">Market Lesson 1</h6>
                                    <asp:Literal ID="marketLesson1StatusLiteral" runat="server" />
                                </div>
                                <a href="MarketLesson1.aspx" class="btn btn-success">Start</a>
                            </div>
                        </div>
                        <div class="card mb-2 shadow-sm">
                            <div class="card-body d-flex justify-content-between align-items-center">
                                <div>
                                    <h6 class="card-title mb-1">Market Lesson 2</h6>
                                    <asp:Literal ID="marketLesson2StatusLiteral" runat="server" />
                                </div>
                                <a href="MarketLesson2.aspx" class="btn btn-success">Start</a>
                            </div>
                        </div>
                        <div class="card mb-2 shadow-sm">
                            <div class="card-body d-flex justify-content-between align-items-center">
                                <div>
                                    <h6 class="card-title mb-1">Market Lesson 3</h6>
                                    <asp:Literal ID="marketLesson3StatusLiteral" runat="server" />
                                </div>
                                <a href="MarketLesson3.aspx" class="btn btn-success">Start</a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Topic 4: Restaurant -->
            <div class="card mb-3 shadow-sm">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <h5 class="mb-0">Topic: Restaurant</h5>
                    <button class="btn btn-sm btn-outline-danger" type="button" data-bs-toggle="collapse" data-bs-target="#restaurantLessons" aria-expanded="false" aria-controls="restaurantLessons">
                        View Lessons
                    </button>
                </div>
                <div class="collapse" id="restaurantLessons">
                    <div class="card-body">
                        <!-- Lesson cards -->
                        <div class="card mb-2 shadow-sm">
                            <div class="card-body d-flex justify-content-between align-items-center">
                                <div>
                                    <h6 class="card-title mb-1">Restaurant Lesson 1</h6>
                                    <asp:Literal ID="restLesson1StatusLiteral" runat="server" />
                                </div>
                                <a href="RestaurantLesson1.aspx" class="btn btn-danger">Start</a>
                            </div>
                        </div>
                        <div class="card mb-2 shadow-sm">
                            <div class="card-body d-flex justify-content-between align-items-center">
                                <div>
                                    <h6 class="card-title mb-1">Restaurant Lesson 2</h6>
                                    <asp:Literal ID="restLesson2StatusLiteral" runat="server" />
                                </div>
                                <a href="RestaurantLesson2.aspx" class="btn btn-danger">Start</a>
                            </div>
                        </div>
                        <div class="card mb-2 shadow-sm">
                            <div class="card-body d-flex justify-content-between align-items-center">
                                <div>
                                    <h6 class="card-title mb-1">Restaurant Lesson 3</h6>
                                    <asp:Literal ID="restLesson3StatusLiteral" runat="server" />
                                </div>
                                <a href="RestaurantLesson3.aspx" class="btn btn-danger">Start</a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

        </div>
    </div>
</div>



</asp:Content>
