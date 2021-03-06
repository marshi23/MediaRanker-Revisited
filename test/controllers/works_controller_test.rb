require 'test_helper'

describe WorksController do
  describe "root" do
    it "succeeds with all media types" do
      # Precondition: there is at least one media of each category
      get root_path
      must_respond_with :success
    end

    it "succeeds with one media type absent" do
      # Precondition: there is at least one media in two of the categories
      @books = nil

      get root_path
      must_respond_with :success
    end

    it "succeeds with no media" do
      # Arrange
      @albums = nil
      @books = nil
      @movies = nil

      # Act
      get root_path

      # Assert
      must_respond_with :success
    end
  end

  CATEGORIES = %w(albums books movies)
  INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

  describe "index" do
    it "succeeds when there are works" do
      # Act
      get works_path

      # Assert
      must_respond_with :success
    end

    it "succeeds when there are no works" do
      # Arrange
      works = Work.all
      works  = nil
      # Act
      get works_path
      # Assert
      must_respond_with :success
    end
  end

  describe "new" do
    it "succeeds" do
      # Act
      get new_work_path

      # Assert
      must_respond_with :success
    end
  end

  describe "create and update" do
    let (:work_hash) do
      {
        work: {
          title: 'A Title',
          creator: 'Meeeeeee',
          description: 'This work right hrrrr',
          publication_year: '2016-04-08',
          category: 'album'
        }
      }
    end

    describe "create" do
      it "creates a work with valid data for a real category" do
        expect {
          post works_path, params: work_hash
        }.must_change 'Work.count', 1

        must_respond_with :redirect
        must_redirect_to work_path(Work.last.id)
      end

      it "renders bad_request and does not update the DB for bogus data" do
        # Arrange
        work_hash[:work][:title] = nil

        # Act-Asssert
        expect {
          post works_path, params: work_hash
        }.wont_change 'Work.count'

      end

      it "renders 400 bad_request for bogus categories" do
        work_hash[:work][:title] = nil

        # Act-Asssert
        expect {
          post works_path, params: work_hash
        }.wont_change 'Work.count'

        must_respond_with :bad_request
      end

    end

    describe "update" do
      it "succeeds for valid data and an extant work ID" do
        # Arrange
        id = works(:poodr).id

        # Act
        expect {
          patch work_path(id), params: work_hash
        }.wont_change 'Work.count'

        must_respond_with :redirect
        must_redirect_to work_path(id)

        new_work = Work.find_by(id: id)

        expect(new_work.title).must_equal work_hash[:work][:title]
        expect(new_work.creator).must_equal work_hash[:work][:creator]
        expect(new_work.description).must_equal work_hash[:work][:description]
      end

      it "renders bad_request for bogus data" do
        # Arrange
        work_hash[:work][:title] = nil
        id = works(:poodr).id

        # Act - Assert
        expect {
          patch work_path(id), params: work_hash
        }.wont_change 'Work.count'

        must_respond_with :bad_request
      end

      it "renders 404 not_found for a bogus work ID" do
        # Arrange
        id = -1

        # Act - Assert
        expect {
          patch work_path(id), params: work_hash
        }.wont_change 'Work.count'

        must_respond_with :not_found
      end
    end
  end
  describe "show" do
    it "succeeds for an extant work ID" do
      # Arrange
      id  = works(:album).id
      # Act
      get works_path(id)
      # Assert
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      # Arrange
      id = -1
      # Act
      get work_path(id)
      # Assert
      must_respond_with :not_found

    end
  end

  describe "edit" do
    it "succeeds for an extant work ID" do
      # Arrange
      id = works(:poodr).id

      # Act
      get edit_work_path(id)

      # Asssert
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      # Arrange
      id = -1

      # Act
      get edit_work_path(id)

      # Asssert
      must_respond_with :not_found
    end
  end


  describe "destroy" do
    it "succeeds for an extant work ID" do
      # Arrange
      id = works(:poodr).id
      category = works(:poodr).category

      # Act - Assert
      expect {
        delete work_path(id)
      }.must_change 'Work.count', -1

      must_respond_with :redirect
      must_redirect_to root_path
      expect(flash[:result_text]).must_equal "Successfully destroyed #{category} #{id}"
    end

    it "renders 404 not_found and does not update the DB for a bogus work ID" do
        id = -1

        expect {
          delete work_path(id)
        }.wont_change 'Work.count'

        must_respond_with :not_found
    end
  end

describe "Logged In user" do
  describe "upvote" do

    it "redirects to the work page if no user is logged in" do
      # Arrange
      id = works(:poodr).id
      # login_user = nil

      # Act

      post upvote_path(id)

      # Assert
      must_respond_with :redirect

    end

    it "redirects to the work page after the user has logged out" do
      # Arrange - Act
      post login_path, params: {user: {username: 'May'}}
      post logout_path

      # Assert
      expect(session[:user_id]).must_equal nil
      must_respond_with :redirect
    end

    it "succeeds for a logged-in user and a fresh user-vote pair" do
        # Arrange
        work = works(:poodr)
        login_user = users(:kari)

        # Figure out how to set the session user_id from a Rails controller test
        # session[:user_id] = login_user.id

        # Act
        post upvote_path(work.id)

        # Assert
        expect{(work.votes.count)}.must_change 'Work.votes.count', 1
    end

  #   it "redirects to the work page if the user has already voted for that work" do
  #
  #   end
  end
end
end
